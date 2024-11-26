import 'package:auction_site/pages/buyerpage.dart';
import 'package:auction_site/gui_elements/mybutton.dart';
import 'package:auction_site/pages/sellerpage.dart';
import 'package:flutter/material.dart';

class Landingpage extends StatelessWidget {
  final dynamic token;
  const Landingpage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary), // Set the color you want
        title: Text('Auctionista!', style: TextStyle(color: Theme.of(context).colorScheme.tertiary, )),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.white, size: 18,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    '${token[1]['user_name']} ${token[1]['user_id']}',
                    style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 16),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const SizedBox(height: 40,),
              newButton(text: 'Sell', ontap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => SellerPage(token: token)) ); 
                }),
              const SizedBox(height: 40,),
              newButton(text: 'Bid', ontap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Buyerpage(token: token)));
                }),
              const SizedBox(height: 40,),
            ], 
          ),
      ),
    );
  }

  login(BuildContext context){
  }
}