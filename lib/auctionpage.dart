import 'package:flutter/material.dart';

class Auctionpage extends StatefulWidget {
  const Auctionpage({super.key, required this.auction, required this.profile});
  final dynamic auction;
  final dynamic profile;

  @override
  State<Auctionpage> createState() => _AuctionpageState();
}

class _AuctionpageState extends State<Auctionpage> {
  @override
  Widget build(BuildContext context) {
    final details = widget.auction;
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary), // Set the color you want
          title: Text(details['item_name'], style: TextStyle(color: Theme.of(context).colorScheme.tertiary,),),
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          actions: [
            Row(
              children: [
                const Icon(Icons.person),
                Text(widget.profile['verification'])
              ],
            )
          ],
      ),
      body: const Column(
        children: [

        ],
      ),
    );
  }
}