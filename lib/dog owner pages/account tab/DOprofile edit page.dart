import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DOEditProfileScreen extends StatefulWidget {
  const DOEditProfileScreen({Key? key}) : super(key: key);

  @override
  _DOEditProfileScreenState createState() => _DOEditProfileScreenState();
}

class _DOEditProfileScreenState extends State<DOEditProfileScreen> {
  late TextEditingController _emailController;
  late TextEditingController _usernameController;

  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with current user information
    final User? user = FirebaseAuth.instance.currentUser;
    _emailController = TextEditingController(text: user?.email ?? '');
    _usernameController = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    // Dispose text controllers when the widget is disposed
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _updateUserInfo(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('User').doc(userId).update(
        {
          'username': _usernameController.text,
          'email': _emailController.text,
        },
      );
      if (kDebugMode) {
        print('User information updated successfully');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error updating User information: $error');
      }
    }
  }

  Future<void> _updateBusinessOwnerInfo(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Business Owner')
          .doc(userId)
          .update(
        {
          'username': _usernameController.text,
          'email': _emailController.text,
        },
      );
      if (kDebugMode) {
        print('Business Owner information updated successfully');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error updating Business Owner information: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: "Roboto",
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Determine account type
                  var accountType = await _getAccountType(user.uid);
                  if (accountType == 'User') {
                    await _updateUserInfo(user.uid);
                  } else if (accountType == 'Business Owner') {
                    await _updateBusinessOwnerInfo(user.uid);
                  }
                }
                Navigator.pop(context); // Navigate back to the previous screen
              },
              icon: const Icon(Icons.save), // Add save icon
              label: const Text('Save'), // Add label
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getAccountType(String userId) async {
    try {
      var businessOwnerDoc = await FirebaseFirestore.instance
          .collection('Business Owner')
          .doc(userId)
          .get();
      if (businessOwnerDoc.exists) {
        return 'Business Owner';
      }
      var userDoc =
          await FirebaseFirestore.instance.collection('User').doc(userId).get();
      if (userDoc.exists) {
        return 'User';
      }
      return 'Unknown';
    } catch (error) {
      return 'Unknown';
    }
  }
}
