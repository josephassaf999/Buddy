import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyDogScreen extends StatefulWidget {
  final String dogId;
  final Map<String, dynamic> dogData;

  MyDogScreen({required this.dogId, required this.dogData});

  @override
  State<MyDogScreen> createState() => MyDogScreenState();
}

class MyDogScreenState extends State<MyDogScreen> {
  late Map<String, dynamic> dogDataMap;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      try {
        // Create a unique file path in Firebase Storage
        String fileName = 'dog_images/${widget.dogId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        print('Uploading file: $fileName');

        // Upload the image to Firebase Storage
        UploadTask uploadTask = _storage.ref().child(fileName).putFile(imageFile);

        // Wait for the upload task to complete
        TaskSnapshot snapshot = await uploadTask;

        // Get the download URL of the uploaded image
        String downloadUrl = await snapshot.ref.getDownloadURL();
        print('Image URL: $downloadUrl');

        // Save the image URL to the Firestore dog subcollection
        await _saveImageUrlToFirestore(downloadUrl);

        // Update the UI with the new image URL (optional, if you want to display immediately)
        setState(() {
          dogDataMap['image_url'] = downloadUrl;
        });

      } catch (e) {
        print('Error uploading image: $e');
      }
    } else {
      print('No image picked');
    }
  }

  Future<void> _saveImageUrlToFirestore(String downloadUrl) async {
    try {
      // Assuming your dog ID is available in widget.dogId
      DocumentReference dogDocRef = FirebaseFirestore.instance
          .collection('Dog owner')  // Assuming this is the parent collection
          .doc(widget.dogId)        // Document reference for this specific dog
          .collection('dogs')       // The subcollection for the dog's info
          .doc(widget.dogId);       // Document for this specific dog (use dogId or another identifier)

      // Update the dog document with the image URL
      await dogDocRef.update({
        'image': downloadUrl,  // Update or create 'image' field with the URL
      });

      print("Image URL saved to Firestore successfully");
    } catch (e) {
      print("Error saving image URL to Firestore: $e");
    }
  }


  @override
  void initState() {
    super.initState();
    dogDataMap = widget.dogData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${dogDataMap['dog_name']}',
          style: TextStyle(
            fontFamily: "Roboto",
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload Pictures',style: TextStyle(color: Colors.black,fontSize: 24,fontWeight: FontWeight.bold),),
            SizedBox(height: 16),
            GridView.builder(
              itemCount: 1,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
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
                                title: Text(
                                  'Choose from Gallery',
                                  style: TextStyle(fontFamily: "Roboto"),
                                ),
                                onTap: () {
                                  _getImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.camera_alt),
                                title: Text(
                                  'Take a Photo',
                                  style: TextStyle(fontFamily: "Roboto"),
                                ),
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
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            Text(
              'Dog Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Divider(height: 0, thickness: 1, color: Colors.grey[300]),
                  ListTile(
                    leading: Icon(Icons.pets, color: Colors.black),
                    title: Text(
                      'Dog Name:',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    subtitle: Text(
                      '${dogDataMap['dog_name']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Divider(height: 0, thickness: 1, color: Colors.grey[300]),
                  ListTile(
                    leading: Icon(Icons.description, color: Colors.black),
                    title: Text(
                      'Description:',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    subtitle: Text(
                      '${dogDataMap['description']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.black),
                    title: Text(
                      'Location:',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    subtitle: Text(
                      '${dogDataMap['location']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Divider(height: 0, thickness: 1, color: Colors.grey[300]),
                  ListTile(
                    leading: Icon(Icons.phone_android, color: Colors.black),
                    title: Text(
                      'Phone Number:',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    subtitle: Text(
                      '${dogDataMap['phone_number']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ), Divider(height: 0, thickness: 1, color: Colors.grey[300]),
                  ListTile(
                    leading: Icon(Icons.cake_outlined, color: Colors.black),
                    title: Text(
                      'Age',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    subtitle: Text(
                      '${dogDataMap['age']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ), Divider(height: 0, thickness: 1, color: Colors.grey[300]),
                  ListTile(
                    leading: Icon(Icons.pets_outlined, color: Colors.black),
                    title: Text(
                      'Breed',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    subtitle: Text(
                      '${dogDataMap['breed']}',
                      style: TextStyle(fontSize: 16),
                    ),
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
