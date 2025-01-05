import 'dart:convert';
import 'dart:typed_data';

import 'package:auction_site/gui_elements/imageCarousel.dart';
import 'package:auction_site/gui_elements/ratingDialouge.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Auctionpage extends StatefulWidget {
  Auctionpage({super.key, required this.token, required this.auction, required this.profile});
  final dynamic auction;
  final dynamic profile;
  final dynamic token;

  @override
  State<Auctionpage> createState() => _AuctionpageState();
  
  List<Uint8List> images = [];
  bool isLoaded = false;
  List<dynamic> highestBids = [];
}

class _AuctionpageState extends State<Auctionpage> {
  final _complaintController = TextEditingController();
  Future<List<dynamic>> getHighestBids()async {
    try{
    final response = await http.get(
      Uri.parse('https://auction-node-server.vercel.app/bids/${widget.auction['auction_id']}'),
      headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Authorization': 'Bearer ${widget.token}'
        },
    );
    if (response.statusCode == 200) {
        return List<dynamic>.from(jsonDecode(response.body));
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    return [];
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeItems();
  }

  Future<void> _initializeItems() async {
      final fetchedBids = await getHighestBids();
      setState(() {
        widget.highestBids = fetchedBids;
      });
  }

  Future<void> placeBid(double amount) async {
  try {
    var url = Uri.parse('https://auction-node-server.vercel.app/bids/placebid');
    
    final response = await http.post(
      url, 
      headers: { 
        'Content-Type': 'application/json', 
        'Connection': 'keep-alive', 
        'Authorization': 'Bearer ${widget.token}'
      }, 
      body: jsonEncode({ // Use jsonEncode
        'user_id': widget.profile['user_id'], 
        'item_id': widget.auction['item_id'], 
        'bid_amount': amount, 
        'auction_id': widget.auction['auction_id']
      })
    );

    // Check the response status and body
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    // Handle different response scenarios
    if (response.statusCode == 200) {
      // Successful bid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bid placed successfully!'))
      );
    } else {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place bid. Message: ${response.body}'))
      );
      
      // Optional: Parse and show more detailed error
      try {
        final errorBody = json.decode(response.body);
        print('Error details: $errorBody');
      } catch (e) {
        print('Could not parse error response');
      }
        }
      } catch (e) {
        // Network or other errors
        print('Error placing bid: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e'))
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.auction;
    print("details $details");
    bool isOpen = widget.auction['status']=='open';
    String topBids = isOpen?'Top Bids':'Winner Bid';
    DateTime targetTime = DateTime.parse(details['end_time']); // Parse the target timestamp
    Duration timeLeft = targetTime.difference(DateTime.now()); // Calculate the difference

    int days = timeLeft.inDays; // Extract days
    int hours = timeLeft.inHours % 24; // Extract hours (modulo 24)
    int minutes = timeLeft.inMinutes % 60; // Extract minutes (modulo 60)

    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary), // Set the color you want
          title: Text(details['item_name'], style: TextStyle(color: Theme.of(context).colorScheme.tertiary,),),
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          actions: [
            Row(
              children: [
              isOpen?
               ElevatedButton(
                onPressed: () => showTextInputDialog(context),
                child: const Text("Bid")
               ):ElevatedButton(
                onPressed: () => {showComplaintDialog()},
                child: const Text("Issue Complaint")
               ),
               // Text(widget.profile['verification'])
              ],
            )
          ],
      ),
      body: Stack(
        children: [
          Positioned(
            width: 420,
            height: 300,
            child: Container(
              width: 300.0, // Fixed width for the container
              height: 150.0, 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ImageCarousel(images: details['images']),
            )
            ),
          Positioned(
            top: MediaQuery.sizeOf(context).height/2,
            right: MediaQuery.sizeOf(context).width/1.5,
            child: const Text('Description', style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          Positioned(
            top: MediaQuery.sizeOf(context).height/1.8,
            right: MediaQuery.sizeOf(context).width/3.8,
            child: Container(
              width: 300.0, // Fixed width for the container
              height: 150.0, 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(details['description'], softWrap: true,),
            )
          ),
          Positioned(
            top: MediaQuery.sizeOf(context).height/2,
            right: MediaQuery.sizeOf(context).width/15,
            child: Text(topBids, style: const TextStyle(fontWeight: FontWeight.bold),),
          ),
          Positioned(
            top: MediaQuery.sizeOf(context).height/1.8,
            right: 5, // Aligns the container to the right-most corner
            child: Container(
              width: 100.0, // Fixed width for the container
              height: 150.0, // Fixed height for the container
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListView.builder(
                
                itemCount: widget.highestBids.length,
                itemBuilder: (context, index) {
                  String x = '';
                  if (widget.highestBids.length < 1) x ='no bidders';
                  else {x = '${widget.highestBids[index]['buyer_id']} ${widget.highestBids[index]['bid_amount']}';}
                  return ListTile(
                    title: Text(
                      "userId: $x",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: recieptionConfirmation(isOpen)
            ),
            Positioned(
            bottom: MediaQuery.sizeOf(context).height/2.5,
            left: 10,
            child: Text('Sellers User ID: ${details['user_id']} rating ${details['avg_rating']}')
            ),
          Positioned(
            bottom: 10,
            left: 10,
            child: recieptionConfirmation(isOpen)
            ),
            Positioned(
              bottom: MediaQuery.sizeOf(context).height/2.5,
              left: 290,
              child: Text('Ends: ${days}d ${hours}h ${minutes}m'),
            ),
        ]
    ));
  }
                

    void showComplaintDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Submit a Complaint"),
          content: TextField(
            controller: _complaintController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Enter your complaint here...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                submitComplaint();
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }
  
  void showTextInputDialog(BuildContext context) {
  // Create a TextEditingController to manage the text input
    final TextEditingController textController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Bid'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Amount in format 0.00',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
            ),
            // Optional: Configure input type
            keyboardType: TextInputType.text,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () async {
                // Get the text from the controller
                String enteredText = textController.text;
                
                // Do something with the text
                print('Entered text: $enteredText');

                await placeBid(double.parse(enteredText));
                
                // Close the dialog
                Navigator.of(context).pop(enteredText);
              },
            ),
          ],
        );
      },
    );
  }
  Widget recieptionConfirmation(bool isOpen){
    dynamic auction_id = widget.auction['auction_id'];
    
    if (widget.highestBids.isNotEmpty && 
      widget.profile != null) {
    
      // Safely check buyer_id against user_id
      if (widget.highestBids[0]['buyer_id'] == widget.profile['user_id'] && !isOpen) {
        return  Row(
          children: [
            const Text(
              "Congrats you won the auction. The auctioneer\n"
              "will be sending your prize soon, press this\n"
              "button if you have received your winnings"
              ),
            (widget.auction['sold'] == false)?ElevatedButton(onPressed: ()=>confirmReceiption(auction_id), child: const Text('Confirm')):
            ElevatedButton(onPressed: ()=>showRatingDialog(context, widget.auction['user_id']), child: const Text("Give Rating", style: TextStyle( fontSize: 12),)) 
            ],
          );
        }
      }
      setState((){});
      return const SizedBox(height: 10);
  }
  Future<void> submitComplaint() async {
    if (_complaintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complaint cannot be empty")),
      );
      return;
    }

    try {
      final url = Uri.parse('https://auction-node-server.vercel.app/complaints/'); // Change to your backend URL
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          "complaint": _complaintController.text,
          "complainer" : widget.profile['user_id'],
          "against": widget.auction['user_id'],
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Complaint submitted successfully")),
        );
        _complaintController.clear();
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit complaint")),
      );
    } 
    }

  Future<void> confirmReceiption(int auction_id) async{
    try {
    var url = Uri.parse('https://auction-node-server.vercel.app/auctions/end/releasepayment/$auction_id');
    
    final response = await http.get(
      url, 
      headers: { 
        'Content-Type': 'application/json', 
        'Connection': 'keep-alive', 
        'Authorization': 'Bearer ${widget.token}'
      }, 
    );

    // Check the response status and body
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    // Handle different response scenarios
    if (response.statusCode == 200) {
      // Successful bid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction Completed Successfully!'))
      );
    } else {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to Complete Transaction. Message: ${response.body}'))
      );
      
      // Optional: Parse and show more detailed error
      try {
        final errorBody = json.decode(response.body);
        print('Error details: $errorBody');
      } catch (e) {
        print('Could not parse error response');
      }
        }
      } catch (e) {
        // Network or other errors
        print('Error placing bid: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e'))
        );
      }
  }
 
}