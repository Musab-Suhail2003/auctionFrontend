import 'package:auction_site/pages/loginpage.dart';
import 'package:auction_site/gui_elements/mycolors.dart';
import 'package:auction_site/pages/registerpage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "auctionista",
      theme: myColors,                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
      debugShowCheckedModeBanner: false,
      routes: {
        '/' : (context) => const Loginpage(),
        '/register': (context) => const Registerpage(),
      },
    );
  }
}
