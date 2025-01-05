import 'dart:convert';

import 'package:auction_site/gui_elements/mybutton.dart';
import 'package:auction_site/pages/landingpage.dart';
import 'package:auction_site/gui_elements/textfield.dart';
import 'package:flutter/material.dart';
import 'package:auction_site/pages/registerpage.dart';
import 'package:http/http.dart' as http;

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  _loginpage createState() => _loginpage();
}

class _loginpage extends State<Loginpage> {
  final String baseUrl = "https://auction-node-server.vercel.app"; // Change to your server's URL
  final String loginEndpoint = "/users/login";
  bool isLoading = false;

  final _username = TextEditingController();
  final _password = TextEditingController();
  late dynamic token;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:  AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary), // Set the color you want
        title: Text('Login', style: TextStyle(color: Theme.of(context).colorScheme.tertiary,),),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          newTextField(hintText: "Username", password: false, controller: _username),
          newTextField(hintText: "Password", password: true, controller: _password),
          isLoading? const CircularProgressIndicator() : newButton(text: 'Login', ontap: () async => handleLogin(context)),
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Registerpage()));
          }, child: const Text("Register"))
      ]
      ),)

    );
  }
  Future handleLogin(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final email = _username.text.trim();
    final password = _password.text.trim();

    final result = await loginUser(email, password);

    setState(() {
      isLoading = false;
    });

    if (result['success']) {
      // Save the token locally if needed (e.g., using shared_preferences)
      // Redirect user to another page
      
      Navigator.push(context, MaterialPageRoute(builder: (context)=>Landingpage(token: result['token'])));
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }
  Future<Map<String, dynamic>> loginUser(String email, String password) async{
    final url = Uri.parse('$baseUrl$loginEndpoint');
    try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Connection' : 'keep-alive'
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data['token']);
      return {
        'success': true,
        'message': 'Login successful',
        'token': [data['token'], data['user']],  // Assumes your server sends a JWT
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