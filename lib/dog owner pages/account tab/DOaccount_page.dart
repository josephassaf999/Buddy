import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../welcome/welcome.dart';
import 'DOprofile edit page.dart';

class DOAccountScreen extends StatelessWidget {
  const DOAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: const Text(
          'Account',
          style: TextStyle(color: Colors.white, fontFamily: "Roboto"),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // GestureDetector moved to the body above "Settings"
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DOEditProfileScreen(),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 40,
              ),
            ),
            const SizedBox(height: 16), // Adding some spacing between avatar and settings
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                fontFamily: "Roboto",
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                'Edit Profile',
                style: TextStyle(fontFamily: "Roboto"),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DOEditProfileScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            const Text(
              'Information',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                fontFamily: "Roboto",
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Dog owner') // Use Dog walker collection
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final userData = snapshot.data!.docs
                    .firstWhere((doc) => doc.id == user!.uid)
                    .data() as Map<String, dynamic>;
                final databaseUsername =
                    userData['username'] ?? 'Not available';
                final databaseEmail = userData['email'] ?? 'Not available';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        'Username: $databaseUsername',
                        style: const TextStyle(fontFamily: "Roboto"),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(
                        'Email: $databaseEmail',
                        style: const TextStyle(fontFamily: "Roboto"),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Call a function to delete the account
                        deleteAccount(user!.uid, context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'Delete Account',
                        style: TextStyle(
                            fontFamily: "Roboto", color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteAccount(String userId, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors. black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  // Delete user document from 'Dog owner' collection in Firestore
                  await FirebaseFirestore.instance
                      .collection('Dog owner')
                      .doc(userId)
                      .delete();

                  // Delete user account from FirebaseAuth
                  await FirebaseAuth.instance.currentUser!.delete();

                  // Navigate back to welcome page
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const WelcomePage()),
                        (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  print('Error deleting account: $e');
                  // Handle error
                }
              },
            ),
          ],
        );
      },
    );
  }
}
