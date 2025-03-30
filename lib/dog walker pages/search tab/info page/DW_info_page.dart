import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  final String item;  // Dog's name
  final String location;  // Dog's location
  final String breed;  // Dog's breed
  final String age;  // Dog's breed
  final List<String> imageUrls;  // List of image URLs for the dog

  InfoPage({
    Key? key,
    required this.item,
    required this.location,
    required this.breed,
    required this.age,
    required this.imageUrls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(
          item,  // Display the dog's name in the AppBar
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image carousel/slider
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              child: imageUrls.isNotEmpty
                  ? PageView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                },
              )
                  : const Center(child: Text("No images available")),
            ),

            // Dog details
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dog's name
                  Text(
                    item,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Dog's location
                  Text(
                    'Location: $location',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Breed and description section
                  Text(
                    '$breed',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Add any other description or information
                  const Text(
                    'This dog is friendly and enjoys long walks. He loves playing in the park and is very social with other dogs.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
