import 'package:flutter/material.dart';
import '../../chat/ChatPage.dart';

class InfoPage extends StatelessWidget {
  final String name;  // Dog's name
  final String location;  // Dog's location
  final String breed;  // Dog's breed
  final String age;  // Dog's age
  final String phone_number;
  final List<String> imageUrls;  // List of image URLs for the dog
  final String description;  // Dog's description
  final String ownerId;  // ✅ Add ownerId as a field

  InfoPage({
    Key? key,
    required this.name,
    required this.location,
    required this.breed,
    required this.age,
    required this.imageUrls,
    required this.phone_number,
    required this.description,
    required this.ownerId, // ✅ Store this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text('Location: $location', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Text('Breed: $breed', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Text('Age: $age', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Text('Phone Number: $phone_number', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text(
                    'Description:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DWChatScreen(
                dogOwnerId: ownerId, // ✅ Pass the actual ownerId
                dogName: name,
              ),
            ),
          );
        },
        child: const Icon(Icons.chat, color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
