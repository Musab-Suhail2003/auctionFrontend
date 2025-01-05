import 'package:flutter/material.dart';

class newTextField extends StatelessWidget {
  final String hintText;
  bool password = false;
  final TextEditingController controller;

  newTextField({super.key, required this.hintText, required this.password, required this.controller});
 
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
      controller: controller,
      obscureText: password,
      
      decoration: InputDecoration(
        
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary)),
        focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)
        ),
        fillColor: Theme.of(context).colorScheme.tertiary,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black45),
      ),
    )
    );
  }
}