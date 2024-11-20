import 'package:auction_site/pages/buyerpage.dart';
import 'package:auction_site/gui_elements/mybutton.dart';
import 'package:auction_site/gui_elements/textfield.dart';
import 'package:flutter/material.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _Registerpage();
}


class _Registerpage extends State<Registerpage> {
  final String baseUrl = "http://10.0.2.2:3000"; // Change to your server's URL
  final String loginEndpoint = "/users/register";
  dynamic token;

  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _repass = TextEditingController();

  String? _errorMessage;

  void _submitForm() { 
    //if(_errorMessage == null){Navigator.push(context, MaterialPageRoute(builder: (context)=> const Buyerpage(token: token,)));}
  } 

  @override
  Widget build(BuildContext context) {
    final controllers = <TextEditingController>[_email, _username, _password, _repass];
    setState(() {
      _errorMessage = null;
      for (var con in controllers) {
      if(con.text == ''){
        _errorMessage = 'Please fill all fields';
        return;
      }
      }
      if(_password.text != _repass.text){
          _errorMessage = 'Passwords dont match';
          return;
      }
    });

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary), // Set the color you want
        centerTitle: true, backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Register", style: TextStyle(color: Theme.of(context).colorScheme.tertiary,),),
        ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
          alignment: Alignment.bottomCenter,
          child: Column(
            children: <Widget>[
              newTextField(hintText: "Username", password: false, controller: _username),
              newTextField(hintText: "Email", password: false, controller: _email),
              newTextField(hintText: "Password", password: true, controller: _password),
              newTextField(hintText: "Retype password", password: true, controller: _repass),
              error(_errorMessage),
              newButton(text: 'Submit', ontap: _submitForm)
            ],
          ),
      ),
    );
  }

  Widget error(String? errorMessage){
    if(errorMessage == null){ return const SizedBox(height: 5,); }

    return Text(errorMessage, textAlign: TextAlign.left, style: const TextStyle(fontSize: 10),);
  }
}