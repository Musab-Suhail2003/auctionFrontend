import 'dart:convert';
import 'package:auction_site/pages/landingpage.dart';
import 'package:http/http.dart' as http;
import 'package:auction_site/gui_elements/mybutton.dart';
import 'package:auction_site/gui_elements/textfield.dart';
import 'package:flutter/material.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _Registerpage();
}


class _Registerpage extends State<Registerpage> {
  final String baseUrl = "https://auction-node-server.vercel.app"; // Change to your server's URL
  final String loginEndpoint = "/users/register";

  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _repass = TextEditingController();

  String? _errorMessage;

 Future _submitForm() async {
  print("sadasdasdasdasd");

  setState(() {
    _errorMessage = null; // Clear error messages before validating
  });

  // Validate inputs
  if (_email.text.isEmpty || _username.text.isEmpty || _password.text.isEmpty || _repass.text.isEmpty) {
    setState(() {
      _errorMessage = 'Please fill all fields';
    });
    return;
  }else if (_password.text != _repass.text) {
    setState(() {
      _errorMessage = 'Passwords do not match';
    });
    return;
  }


  // Prepare data
  final body = {
    'email': _email.text,
    'user_name': _username.text,
    'password': _password.text,
  };
  print(body);

  try {
    // Send POST request
    final url = Uri.parse('$baseUrl$loginEndpoint');
    print(url);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Connection': 'keep-alive'
        },
      body: jsonEncode(body),
    );

    // Handle server response
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseBody = jsonDecode(response.body);
      final token = [responseBody['token'], responseBody['user']];
      print(token[1]);
       // Assuming the server returns a token
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Landingpage(token: token)),
      );
    } else {
      final errorResponse = jsonDecode(response.body);
      setState(() {
        _errorMessage = errorResponse['error'] ?? 'Registration failed';
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Failed to connect to the server';
    });
  }
}


  @override
  Widget build(BuildContext context) {
    //final controllers = <TextEditingController>[_email, _username, _password, _repass];

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary), // Set the color you want
        centerTitle: true, backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Register", style: TextStyle(color: Theme.of(context).colorScheme.tertiary,),),
        ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 5),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              newTextField(hintText: "Username", password: false, controller: _username),
              newTextField(hintText: "Email", password: false, controller: _email),
              newTextField(hintText: "Password", password: true, controller: _password),
              newTextField(hintText: "Retype password", password: true, controller: _repass),
              error(_errorMessage),
              newButton(text: 'Submit', ontap: () async => _submitForm())
            ],
          ),
      ),
    );
  }

  Widget error(String? errorMessage){
    if(errorMessage == null){ return const SizedBox(height: 5,); }

    return Text('$errorMessage!', textAlign: TextAlign.left, style: const TextStyle(fontSize: 8),);
  }
}