import 'package:flutter/material.dart';

class Sellerpage extends StatelessWidget {
  final dynamic token;
  const Sellerpage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary), // Set the color you want
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: Text("Seller Dashboard", style: TextStyle(color: Theme.of(context).colorScheme.tertiary),),
      ),
    );
  }
}