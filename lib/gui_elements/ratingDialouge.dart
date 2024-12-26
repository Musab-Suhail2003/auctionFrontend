import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RatingDialog extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rate Your Experience'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('On a scale of 1 to 5, how would you rate your experience?'),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              int rating = index + 1;
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Return the selected rating
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    rating.toString(),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
}

// Example usage in your app
void showRatingDialog(BuildContext context, int user_id) async {
  final rating = await showDialog<int>(
    context: context,
    builder: (context) => RatingDialog(),
  );

  if (rating != null) {
    submitRating(context, rating, user_id);
    print('User selected rating: $rating');
    // You can handle the rating here, e.g., send it to your backend
  }
}

Future<void> submitRating(BuildContext context, int rating, int user_id) async {

    try {
      final url = Uri.parse('http://10.0.2.2:3000/users/rating'); // Change to your backend URL
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "rating": rating,
          "user_id": user_id
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("rating submitted successfully")),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit rating")),
      );
    } 
    }


