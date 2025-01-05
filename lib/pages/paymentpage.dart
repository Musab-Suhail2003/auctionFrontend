import 'dart:convert';

import 'package:auction_site/gui_elements/mybutton.dart';
import 'package:auction_site/gui_elements/textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class Paymentpage extends StatefulWidget {
  final dynamic token0;
  const Paymentpage({super.key, required this.token0});
  @override
  State<Paymentpage> createState() => _PaymentpageState();
}

class _PaymentpageState extends State<Paymentpage> {
  @override
  Widget build(BuildContext context) {
    final profile = widget.token0[1];
    final token = widget.token0[0];
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary), // Set the color you want
        title: Text('Buy Coin!', style: TextStyle(color: Theme.of(context).colorScheme.tertiary, )),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          newTextField(hintText: 'Enter Amount', password: false, controller: controller),
          const SizedBox(height: 10,),
          newButton(text: "Enter", ontap: ()async=>getMoney(double.parse(controller.text), profile['user_id'], token))
        ],
        ),
      ),
    );
  }
  Future<void> getMoney(double amount, int user_id, String token) async {
    try {
    var url = Uri.parse('https://auction-node-server.vercel.app/users/wallet');
    
    final response = await http.post(
      url, 
      headers: { 
        'Content-Type': 'application/json', 
        'Connection': 'keep-alive', 
        'Authorization': 'Bearer $token'
      }, 
      body: jsonEncode({ // Use jsonEncode
        'user_id': user_id, 
        'amount': amount, 
      })
    );

    // Check the response status and body
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    // Handle different response scenarios
    if (response.statusCode == 200) {
      // Successful bid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coin added successfully!'))
      );
    } else {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed Add Coin. Message: ${response.body}'))
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

