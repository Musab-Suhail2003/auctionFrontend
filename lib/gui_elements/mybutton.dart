import 'package:flutter/material.dart';

class newButton extends StatelessWidget {
  final String text;
  final void Function() ontap;
  const newButton({super.key, required this.text, required this.ontap});
  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;
    return  GestureDetector(
      onTap: ontap,
      child:Container(
        decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.all(18),
        margin: EdgeInsets.symmetric(horizontal: screen.width * 0.3, vertical: 10),
        child: Center(
          child: Text(text, style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.tertiary),),
        )
      )
      );
  }
}