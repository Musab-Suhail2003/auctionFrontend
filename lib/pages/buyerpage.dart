import 'dart:convert';
import 'dart:ffi';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Buyerpage extends StatefulWidget {
  final dynamic token;

  Buyerpage({required this.token});


  @override
  _BuyerpageState createState() => _BuyerpageState();
}

class _BuyerpageState extends State<Buyerpage> {
  final String baseUrl = "http://10.0.2.2:3000"; // Your server's URL
  final String auctionlist = "/auctions/active";
  bool isLoading = true;
  dynamic data = [];
  dynamic profile = {};

  @override
  void initState() {
    print(widget.token);

    super.initState();
    fetchData(); 
    isLoading = false;// Fetch data asynchronously
  }

  Future<void> fetchData() async {
    final fetchedData = await getAuctions(widget.token[0]);
    final fetchProfile = await getProfile(widget.token);
    setState(() {
      data = fetchedData;
      profile = fetchProfile;
      isLoading = false; // Stop showing the loader
    });
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
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
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
        auctiontab(),
        const Placeholder()
      ])
    ));
  }

  Widget auctiontab() {
    return isLoading
        ? const Center(child: CircularProgressIndicator()) // Show loading spinner
        : ListView.builder(
                itemCount: data.length,
                physics: const ScrollPhysics(),
                itemBuilder: (context, index) {
                  var i = data[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 7,
                          color: Theme.of(context).colorScheme.primary,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 5),
                    child: ListTile(

                      title: Text(i['item_name']), // Ensure this is a string
                      trailing: Text("top bid: ${i['min_bid']}", style: TextStyle(color: Theme.of(context).colorScheme.primary),), // Convert to string
                    ),
                  );
                },
              
              );
  }
  Future<dynamic> getProfile(token) async{
    final url = Uri.parse("$baseUrl/users/profile/${token[1]}");
    try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Connection' : 'keep-alive',
        'Authorization':  token[0]
      },
    );

    if (response.statusCode == 200) {
      final profile = jsonDecode(response.body);
      print(profile);
      return profile;
    } else {
      final error = jsonDecode(response.body);
      print(error);
      return {
        'wallet':0
      };
    }
    } catch (e) {
      print(e.toString());
      return {
        'wallet': 0
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
          'Authorization': token
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
