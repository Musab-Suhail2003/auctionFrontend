import 'package:auction_site/gui_elements/mybutton.dart';
import 'package:auction_site/gui_elements/textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerificationForm extends StatefulWidget {
  final dynamic user_id;
  const VerificationForm({required this.user_id});

  @override
  _VerificationFormState createState() => _VerificationFormState();
}

class _VerificationFormState extends State<VerificationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _phNumberController = TextEditingController();

  Future<void> _submitVerification() async {
    final String apiUrl = "https://auction-node-server.vercel.app/verification/";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "cnic": _cnicController.text,
          "fullname": _fullnameController.text,
          "ph_number": _phNumberController.text,
          "user_id": widget.user_id,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification record created successfully!")),
        );
      } else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("verification record already exists.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary), // Set the color you want
        title: Text('Verification', style: TextStyle(color: Theme.of(context).colorScheme.tertiary, )),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              newTextField(hintText: "CNIC", password: false, controller: _cnicController),
              newTextField(hintText: "Full Name", password: false, controller: _fullnameController),
              newTextField(hintText: "Phone Number", password: false, controller: _phNumberController),
              SizedBox(height: 20),
              newButton(text: 'Submit', ontap: _submitVerification),
            ],
          ),
        ),
      ),
    );
  }
}
