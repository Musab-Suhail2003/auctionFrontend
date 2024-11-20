import 'package:flutter/material.dart';

class Sellerpage extends StatelessWidget {
  final dynamic token;
  const Sellerpage({super.key, required this.token});

    @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text('Two Tabs Example', style: TextStyle(color: Theme.of(context).colorScheme.tertiary),),
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.tertiary,
            indicatorColor: Theme.of(context).colorScheme.tertiary,
            tabs: [
              Tab(icon: Icon(Icons.store, color: Theme.of(context).colorScheme.tertiary,), text: "Items", ),
              Tab(icon: Icon(Icons.store, color: Theme.of(context).colorScheme.tertiary,), text: "Settings"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text('Home Tab Content')),
            Center(child: Text('Settings Tab Content')),
          ],
        ),
      ),
    );
  }

}