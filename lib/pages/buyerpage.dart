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
  dynamic data;

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data asynchronously
  }

  Future<void> fetchData() async {
    final fetchedData = await getAuctions(widget.token);
    setState(() {
      data = fetchedData;
      isLoading = false; // Stop showing the loader
    });
  }

  Future<dynamic> getAuctions(token) async {
    final url = Uri.parse('$baseUrl$auctionlist');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Authorization': token[0]
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    widget.token[2]['wallet'],
                    style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 16),
                  ),
                ),
              ],
            ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner
          : (data != null && data.isNotEmpty)
              ? ListView.builder(
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
                        trailing: Text("current bid: ${i['min_bid']}", style: TextStyle(color: Theme.of(context).colorScheme.primary),), // Convert to string
                      ),
                    );
                  },
                )
              : Center(
                  child: Text('No auctions available'),
                ),
    );
  }
}
