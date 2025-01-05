import 'dart:convert';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageCarousel extends StatefulWidget {
  final List<dynamic> images;

  const ImageCarousel({Key? key, required this.images}) : super(key: key);
  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {

  List<Image> images = [];
  bool isLoading = true;


  @override
  void initState() {
    print("TESTING IMAGES");
        print(widget.images);

    super.initState();
    getImages();
  }

  Future<List<Widget>> getImages() async {
    setState(() {
      isLoading = true;
    });

    try {
      final List<dynamic> imageUrls = widget.images;

      for (String url in imageUrls) {
        print(url);
        images.add(
          Image.network(
            "https://auction-node-server.vercel.app/$url",
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.error_outline, color: Colors.red),
              );
            },
          ),
        );
      }

      setState(() {
        print('${images.length} ads');
        isLoading = false;
      });
      
      return images;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading images: $e');
      return [
        const Center(
          child: Icon(Icons.error_outline, color: Colors.red, size: 50),
        )
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (images.isEmpty) {
      return const Center(child: Text('No images available'));
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 400.0,
        autoPlay: true,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
        aspectRatio: 16 / 9,
      ),
      items: images.map((img) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: Image(
                image: img.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Image not available'));
                },
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
