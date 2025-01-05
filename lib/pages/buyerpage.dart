import 'dart:convert';
import 'package:auction_site/pages/auctionpage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Buyerpage extends StatefulWidget {
  final dynamic token;

  const Buyerpage({super.key, required this.token});


  @override
  _BuyerpageState createState() => _BuyerpageState();
}

class _BuyerpageState extends State<Buyerpage> {
  final String baseUrl = "https://auction-node-server.vercel.app"; // Your server's URL
  final String auctionlist = "/auctions/active";
  final String bidList = "/bids/mybids/";
  final String highestbid = "/bids/";
  bool isLoading = true;
  dynamic data = [];
  dynamic profile = {};
  dynamic bids = [];
  late dynamic highestBid;

  @override
  void initState() {
    print(widget.token);

    super.initState();
    fetchData(); 
    isLoading = false; // Fetch data asynchronously
  }

  Future<void> fetchData() async {
    final fetchedData = await getAuctions(widget.token[0]);
    final fetchProfile = await getProfile(widget.token[0], widget.token[1]);
    final fetchBids = await getBids(widget.token[0], widget.token[1]);
    
    if (mounted) {
      setState(() {
        data = fetchedData;
        profile = fetchProfile;
        bids = fetchBids;
      });
    }
  }

  @override
  void dispose() {
    // Perform any necessary cleanup here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.tertiary,
        ),
        centerTitle: true,
        title: Text(
          "Buyers Page!",
          style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
        ),
        actions: [
            Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 18,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    '${profile['wallet']}',
                    style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 16),
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.tertiary,
            indicatorColor: Theme.of(context).colorScheme.tertiary,
            tabs: [
              Tab(icon: Icon(Icons.store, color: Theme.of(context).colorScheme.tertiary,), text: "auctions", ),
              Tab(icon: Icon(Icons.money, color: Theme.of(context).colorScheme.tertiary,), text: "My Bids"),
            ],
          ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: TabBarView(children: [
        AuctionTab(data: data, profile: profile, token: widget.token[0]),
        bidtab()
      ])
    ));
  }

  Widget bidtab(){
    print(bids);
    return (isLoading  || data.length == 0 ||bids == null)
        ? const Center(child: Text("Couldnt Find Bids"),)
        : ListView.builder(
            itemCount: (bids.length < data.length) ? bids.length : data.length,
            physics: const ScrollPhysics(),
            itemBuilder: (context, index){
              var i = bids[index];
              var j = data[index];

              return bidTile(bidinfo: i, auction: j);
            });
  }

  Widget auctiontab() {
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredData = data; // Initially, show all data

  void _filterData(String query) {
    setState(() {
      filteredData = data
          .where((auction) => auction['title']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase())) // Replace 'title' with the relevant key
          .toList();
    });
  }

  return Column(
    children: [
      // Search bar
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: searchController,
          onChanged: _filterData,
          decoration: InputDecoration(
            labelText: "Search Auctions",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      Expanded(
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // Loading state
            : filteredData.isEmpty
                ? const Center(
                    child: Text(
                      "No auctions found!",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredData.length,
                    physics: const ScrollPhysics(),
                    itemBuilder: (context, index) {
                      var auction = filteredData[index];
                      return auctionTile(
                        auction: auction,
                        profile: profile,
                        token: widget.token[0],
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Future<dynamic> getProfile(token, id) async{
    final url = Uri.parse("$baseUrl/users/profile/${id['user_id']}");
    print(token);
    try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Connection' : 'keep-alive',
        'Authorization':  'Bearer $token'
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final profile = jsonDecode(response.body);
      return profile;
    } else {
      final error = jsonDecode(response.body);
      print(error);
      return {
        'wallet': null
      };
    }
    } catch (e) {
      print(e.toString());
      return {
        'wallet': null
      };
    }
  }

  Future<dynamic> getAuctions(token) async {
    final url = Uri.parse('$baseUrl$auctionlist');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    return null;
  }
  
  Future<dynamic> getBids(token, profile) async{
    final url = Uri.parse('$baseUrl$bidList${profile['user_id']}');
    print(url);
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error: ${response.body}');
      }
      } catch (e) {
        print('Exception: $e');
      }
      return null;
    }
}
class bidTile extends StatelessWidget{
  final dynamic bidinfo;
  final dynamic auction;
  bidTile({required this.bidinfo, required this.auction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 7,
            color: Theme.of(context).colorScheme.primary,
            offset: const Offset(0, 3),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 5),
      child: ListTile(
        
        title: Text(auction['item_name']),
        trailing: Text("bid: ${bidinfo['bid_amount']}", style: TextStyle(color: Theme.of(context).colorScheme.primary),), // Convert to string
      ),
    );
  }
}

class auctionTile extends StatelessWidget {
  const auctionTile({
    super.key,
    required this.auction,
    required this.profile,
    required this.token,
  });
  final dynamic profile;
  final dynamic auction;
  final dynamic token;

  @override
  Widget build(BuildContext context) {
    bool isMine = auction['user_id'] == profile['user_id'];
    String x = isMine? '(you)':'';
    bool isOpen = auction['status'] == 'open';
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Auctionpage(auction: auction, profile: profile, token: token,)));
      },
      child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 7,
            color: Theme.of(context).colorScheme.primary,
            offset: const Offset(0, 3),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 5),
      child: ListTile(
        leading: isOpen ? null : const Text('closed', style: TextStyle(color: Colors.red),),
        title: Text('${auction['item_name']} $x'), // Ensure this is a string
        trailing: Text("min bid: ${auction['min_bid']}", style: TextStyle(color: Theme.of(context).colorScheme.primary),), // Convert to string
      ),
    )
    );
  }
}
class AuctionTab extends StatefulWidget {
  final List<dynamic> data;
  final dynamic profile;
  final String token;

  const AuctionTab({Key? key, required this.data, required this.profile, required this.token})
      : super(key: key);

  @override
  State<AuctionTab> createState() => _AuctionTabState();
}

class _AuctionTabState extends State<AuctionTab> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredData = [];
  String searchMode = "Name"; // Default search mode
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    filteredData = widget.data; // Initialize with the full dataset
  }

  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredData = widget.data; // Reset to original data if query is empty
      } else {
        if (searchMode == "Name") {
          filteredData = widget.data
              .where((auction) => auction['item_name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase())) // Replace 'title' with the correct key for auction names
              .toList();
        } else if (searchMode == "Category") {
          filteredData = widget.data
              .where((auction) => auction['category_name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase())) // Replace 'category' with the correct key for categories
              .toList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search mode selector
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text("Search by: "),
              DropdownButton<String>(
                value: searchMode,
                onChanged: (String? newMode) {
                  if (newMode != null) {
                    setState(() {
                      searchMode = newMode;
                      _filterData(searchController.text); // Reapply filter with the new mode
                    });
                  }
                },
                items: ["Name", "Category"].map((String mode) {
                  return DropdownMenuItem<String>(
                    value: mode,
                    child: Text(mode),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        // Search bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            onChanged: _filterData,
            decoration: InputDecoration(
              labelText: "Search Auctions",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        // Display filtered results
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredData.isEmpty
                  ? const Center(
                      child: Text(
                        "No auctions found!",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredData.length,
                      physics: const ScrollPhysics(),
                      itemBuilder: (context, index) {
                        var auction = filteredData[index];
                        return auctionTile(
                          auction: auction,
                          profile: widget.profile,
                          token: widget.token,
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
