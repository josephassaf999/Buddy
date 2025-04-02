import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyDogScreen extends StatefulWidget {
  final String ownerId; // Owner's ID
  final String dogId; // Dog's ID
  final Map<String, dynamic> dogData; // Dog's data (e.g., name, description)

  // Constructor that takes ownerId, dogId, and dogData
  MyDogScreen({
    required this.ownerId,
    required this.dogId,
    required this.dogData,
  });

  @override
  State<MyDogScreen> createState() => MyDogScreenState();
}

class MyDogScreenState extends State<MyDogScreen> {
  late Map<String, dynamic> dogDataMap;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> imageUrls = []; // Store uploaded image URLs

  @override
  void initState() {
    super.initState();
    dogDataMap = widget.dogData;
    _loadExistingImages();
  }

  // 🟢 Load existing images from Firestore
  Future<void> _loadExistingImages() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Dog owner')
          .doc(widget.ownerId)
          .collection('dogs')
          .doc(widget.dogId)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          imageUrls = List<String>.from(data['images'] ?? []);
        });
      }
    } catch (e) {
      print("Error loading images: $e");
    }
  }

  // 🟢 Pick an image from the gallery or camera
  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _uploadImage(imageFile);
    } else {
      print('No image selected.');
    }
  }

  // 🔹 Upload image to Firebase Storage and get URL
  Future<void> _uploadImage(File imageFile) async {
    try {
      String fileName = 'dog_images/${widget.dogId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});

      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("✅ Upload Success: $downloadUrl");

      await _saveImageUrlToFirestore(downloadUrl); // Save to Firestore

      // Update UI
      setState(() {
        imageUrls.add(downloadUrl);
      });
    } catch (e) {
      print("❌ Upload Error: $e");
    }
  }

  // 🔹 Save image URL to Firestore in the 'dogs' subcollection
  Future<void> _saveImageUrlToFirestore(String downloadUrl) async {
    try {
      DocumentReference dogDocRef = FirebaseFirestore.instance
          .collection('Dog owner')
          .doc(widget.ownerId)
          .collection('dogs')
          .doc(widget.dogId);

      await dogDocRef.update({
        'images': FieldValue.arrayUnion([downloadUrl]), // Save as an array
      });

      print("✅ Image URL saved successfully");
    } catch (e) {
      print("❌ Error saving image URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${dogDataMap['dog_name']}',
          style: TextStyle(fontFamily: "Roboto", color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload Pictures', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),

            // 🟢 Display Uploaded Images
            GridView.builder(
              itemCount: imageUrls.length + 1, // +1 for upload button
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                if (index == imageUrls.length) {
                  return GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.photo_library),
                                  title: Text('Choose from Gallery', style: TextStyle(fontFamily: "Roboto")),
                                  onTap: () {
                                    _getImage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.camera_alt),
                                  title: Text('Take a Photo', style: TextStyle(fontFamily: "Roboto")),
                                  onTap: () {
                                    _getImage(ImageSource.camera);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Icon(Icons.camera_alt, color: Colors.black)),
                    ),
                  );
                } else {
                  return Image.network(imageUrls[index], fit: BoxFit.cover);
                }
              },
            ),

            SizedBox(height: 24),

            Text('Dog Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 16),

            // Dog Details
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.pets, color: Colors.black),
                    title: Text('Dog Name:', style: TextStyle(fontSize: 16, color: Colors.black)),
                    subtitle: Text('${dogDataMap['dog_name']}', style: TextStyle(fontSize: 16)),
                  ),
                  ListTile(
                    leading: Icon(Icons.description, color: Colors.black),
                    title: Text('Description:', style: TextStyle(fontSize: 16, color: Colors.black)),
                    subtitle: Text('${dogDataMap['description']}', style: TextStyle(fontSize: 16)),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.black),
                    title: Text('Location:', style: TextStyle(fontSize: 16, color: Colors.black)),
                    subtitle: Text('${dogDataMap['location']}', style: TextStyle(fontSize: 16)),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone_android, color: Colors.black),
                    title: Text('Phone Number:', style: TextStyle(fontSize: 16, color: Colors.black)),
                    subtitle: Text('${dogDataMap['phone_number']}', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
