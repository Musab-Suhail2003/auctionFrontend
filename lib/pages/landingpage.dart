import 'package:auction_site/pages/buyerpage.dart';
import 'package:auction_site/gui_elements/mybutton.dart';
import 'package:auction_site/pages/sellerpage.dart';
import 'package:auction_site/pages/verificationpage.dart';
import 'package:auction_site/pages/paymentpage.dart';
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
                const SizedBox(width: 20,),
                const Icon(Icons.wallet),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    '${token[1]['wallet']}',
                    style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 16),
                  ),
                )
              ],
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const SizedBox(height: 40,),
              newButton(text: 'Add to Wallet', ontap: (){
                if(token[1]['verification'] == 'verified') {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Paymentpage(token0: token)));
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You Arent Verified')));
                }
                }),
              const SizedBox(height: 40,),
              newButton(text: 'Sell', ontap: (){
                if(token[1]['verification'] == 'verified') {Navigator.push(context, MaterialPageRoute(builder: (context) => SellerPage(token: token)) );}
                else{
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You Arent Verified')));
                }
                }),
              const SizedBox(height: 40,),
              newButton(text: 'See Auctions', ontap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Buyerpage(token: token)));
                }),
              const SizedBox(height: 40,),
              verificationlogo(context),
              const SizedBox(height: 19,)
            ], 
          ),
      ),

    );
  }

  Widget verificationlogo(BuildContext context){
    dynamic profile = token[1];
    dynamic iconcolor = Colors.red;
    if (profile['verification'] == 'verified'){
      iconcolor = Colors.green;
    }
    return GestureDetector(
      
      child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 40, color: iconcolor), // Icon at the left
                const SizedBox(width: 16), // Spacing between icon and text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile['user_name'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          profile['verification'],
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '  id ${profile['user_id']}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
      onTap: (){ 
        profile['verification'] != 'verified'?
        Navigator.push(context, MaterialPageRoute(builder: (context)=>VerificationForm(user_id: profile['user_id'])))
        :ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Already Verified")));
      },
    );
  }
}