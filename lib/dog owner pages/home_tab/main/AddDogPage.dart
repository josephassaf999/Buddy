import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AddDogsScreen extends StatefulWidget {
  @override
  _AddDogsScreenState createState() => _AddDogsScreenState();
}

class _AddDogsScreenState extends State<AddDogsScreen> {
  final _formKey = GlobalKey<FormState>();

  String _dogName = '';
  String _description = '';
  String _location = '';
  String _phoneNumber = '';
  String _age = '';
  String _breed = '';
  String _imageUrl = ''; // Store the image URL here

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadImage(File imageFile) async {
    try {
      String fileName = 'dog_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      // Upload the image to Firebase Storage
      UploadTask uploadTask = _storage.ref().child(fileName).putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadUrl; // Store the image URL here
      });
      print('Image uploaded successfully: $downloadUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _uploadImage(imageFile);
    } else {
      print('No image selected.');
    }
  }

  Future<void> _addDogToFirestore(BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Add the dog to the 'dogs' subcollection under the current user
        DocumentReference dogRef = await FirebaseFirestore.instance
            .collection('Dog owner')
            .doc(user.uid)
            .collection('dogs')
            .add({
          'dog_name': _dogName,
          'description': _description,
          'location': _location,
          'phone_number': _phoneNumber,
          'age': _age,
          'breed': _breed,
          'image': _imageUrl,  // Add the image URL to Firestore
        });

        // Save the dog ID back into the dog's document
        String dogId = dogRef.id;
        await dogRef.update({'dog_id': dogId});

        // Additionally, save the phone number in the owner's document
        await FirebaseFirestore.instance
            .collection('Dog owner')
            .doc(user.uid)
            .update({
          'phone_number': _phoneNumber,
        });

        print('Added dog with ID: $dogId');
        Navigator.pop(context);  // Navigate back after successful addition
      } else {
        print('User is not logged in');
      }
    } catch (e) {
      print('Error saving dog: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Dog',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Dog Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a dog name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _dogName = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _location = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _phoneNumber = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the dog age';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _age = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Breed',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the dog breed';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _breed = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // Add Image Upload Button
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Pick an Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addDogToFirestore(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Add Dog',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
