import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Buyerpage extends StatelessWidget {
  final dynamic token;
  Buyerpage({super.key, required this.token});
  final String baseUrl = "http://10.0.2.2:3000"; // Change to your server's URL
  final String loginEndpoint = "/auctions/active";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary), // Set the color you want
        centerTitle: true, 
        title: Text("Buyers Page!", style: TextStyle(color: Theme.of(context).colorScheme.tertiary),), 
        backgroundColor: Theme.of(context).colorScheme.primary, 
        ),
      
    );
  }

  Future getAuctions async {
    final url = Uri.parse('$baseUrl$loginEndpoint');
    try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Connection' : 'keep-alive',
        'Authorization': token[0]
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'message': 'Login successful',
        'token': data['token'], // Assumes your server sends a JWT
      };
    } else {
      final error = jsonDecode(response.body);
      return {
        'success': false,
        'message': error['error'] ?? 'Unknown error occurred',
      };
    }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to the server',
      };
    }
  }
}