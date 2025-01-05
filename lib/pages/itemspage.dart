import 'package:auction_site/gui_elements/imageCarousel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Itemspage extends StatefulWidget {
  final dynamic itemData;
  final dynamic token;
  const Itemspage({super.key, required this.itemData, required this.token});

  @override
  State<Itemspage> createState() => _ItemspageState();
}

class _ItemspageState extends State<Itemspage> {
  bool _isLoading = false;
  List<Widget> _imageWidgets = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.itemData;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
        centerTitle: true,
        title: Text('${data['sold']?'(sold)':''}  ${data['item_name']}', style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 25),),
        actions: [
          ElevatedButton(
      onPressed: _isLoading ? null : _showEndTimeDialog,
      style: ElevatedButton.styleFrom(
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Place on Auction'),
    )
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Stack(
        children: [
          Positioned(
            width: 420,
            height: 300,
            child: Container(
              width: 300.0, // Fixed width for the container
              height: 150.0, 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ImageCarousel(images: data['images']),
            )
            ),
          Positioned(
            top: MediaQuery.sizeOf(context).height/2,
            right: MediaQuery.sizeOf(context).width/1.5,
            child: const Text('Description', style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          Positioned(
            top: MediaQuery.sizeOf(context).height/1.8,
            right: 5,
            child: Container(
              width: 400.0, // Fixed width for the container
              height: 150.0, 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(data['description'], softWrap: true,),
            )
          ),
          
        ]
    )
    );
  }
  Future<void> putOnAuction(int days, int hours, int min)async{
    try {
      // Replace with your backend endpoint
      const String apiUrl = 'https://auction-node-server.vercel.app/auctions/';

      // Set the required end time (e.g., 24 hours from now)
      final DateTime endTime = DateTime.now().add(Duration(days: days, hours: hours, minutes: min));
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}'
        },
        body: jsonEncode({
          'user_id' : widget.itemData['user_id'],
          'item_id': widget.itemData['item_id'], // Pass the item_id
          'end_time': endTime.toIso8601String(), // Send the ISO 8601 formatted end time
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item placed on auction: ${responseData['message']}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place item on auction: ${response.body}')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> uploadImages(List<XFile> images) async {
  const String apiUrl = "https://auction-node-server.vercel.app.vercel.app/";

  // Create multipart request
  var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

  // Add images to the request
  for (var image in images) {
    var stream = http.ByteStream(image.openRead());
    var length = await image.length();
    var multipartFile = http.MultipartFile('images', stream, length,
        filename: image.name);
    request.files.add(multipartFile);
  }

  try {
    var response = await request.send();

    if (response.statusCode == 200) {
      print('Images uploaded successfully');
    } else {
      print('Failed to upload images');
    }
  } catch (e) {
    print('Error: $e');
  }
}

// Call this function to pick and upload images
Future<void> pickAndUploadImages() async {
  final ImagePicker picker = ImagePicker();
  final List<XFile>? images = await picker.pickMultiImage();

  if (images != null && images.isNotEmpty) {
    await uploadImages(images);
  } else {
    print('No images selected');
  }
}

  Future<void> _showEndTimeDialog() async {
    final daysController = TextEditingController();
    final hoursController = TextEditingController();
    final minController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set Auction End Time"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: daysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Days",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Hours",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: minController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "minutes",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final int days = int.tryParse(daysController.text) ?? 0;
                final int hours = int.tryParse(hoursController.text) ?? 0;
                final int min = int.tryParse(minController.text) ?? 0;

                Navigator.pop(context); // Close the dialog
                putOnAuction(days, hours, min); // Call the API
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }
}


