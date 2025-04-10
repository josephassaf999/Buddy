import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  final String name;  // Dog's name
  final String location;  // Dog's location
  final String breed;  // Dog's breed
  final String age;  // Dog's age
  final String phone_number;
  final List<String> imageUrls;  // List of image URLs for the dog
  final String description;  // Dog's description

  InfoPage({
    Key? key,
    required this.name,
    required this.location,
    required this.breed,
    required this.age,
    required this.imageUrls,
    required this.phone_number,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text(
          name,  // Display the dog's name in the AppBar
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image carousel/slider
            Container(
              height: 450,
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

            // Dog details container
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text('Location: $location', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 12),
                  Text('Breed: $breed', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 12),
                  Text('Age: $age', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 12),
                  Text('Phone Number: $phone_number', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text(
                    'Description:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 8),
                  Text(description, style: TextStyle(fontSize: 16)),
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
