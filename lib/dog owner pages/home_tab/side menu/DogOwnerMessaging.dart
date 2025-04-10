import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DOChatPage.dart'; // Ensure the correct import for your chat screen

class DOMessaging extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messaging',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Dog walker').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                Map<String, dynamic> dogWalkerData = document.data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () async {
                    String currentDogOwnerId = FirebaseAuth.instance.currentUser?.uid ?? '';
                    String otherDogWalkerId = document.id;
                    Map<String, dynamic> otherDogWalkerData = dogWalkerData;

                    // Generate a unique conversationId (walkerId-ownerId)
                    String conversationId = currentDogOwnerId.compareTo(otherDogWalkerId) < 0
                        ? '$currentDogOwnerId-$otherDogWalkerId'
                        : '$otherDogWalkerId-$currentDogOwnerId';

                    // Check if the conversation already exists
                    DocumentSnapshot conversationSnapshot = await FirebaseFirestore.instance
                        .collection('Chats')
                        .doc(conversationId)
                        .get();

                    if (!conversationSnapshot.exists) {
                      // If the conversation does not exist, create a new conversation
                      FirebaseFirestore.instance.collection('Chats')
                          .doc(conversationId)
                          .set({
                        'participants': [currentDogOwnerId, otherDogWalkerId],
                        'lastMessageTimestamp': FieldValue.serverTimestamp(),
                      });
                    }

                    // Fetch the Dog Owner's data (such as name) and pass it to the chat screen
                    FirebaseFirestore.instance.collection('Dog owner').doc(currentDogOwnerId).get().then((dogOwnerDoc) {
                      Map<String, dynamic> dogOwnerData = dogOwnerDoc.data() as Map<String, dynamic>;

                      // Navigate to the chat screen with the conversation ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DOChatScreen(
                            senderUserId: currentDogOwnerId,
                            recipientUserId: otherDogWalkerId,
                            recipientUserData: otherDogWalkerData,
                            conversationId: conversationId, // Pass the conversationId
                            senderUserData: dogOwnerData, // Pass the Dog Owner's data
                          ),
                        ),
                      );
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[300]!, // Border color
                          width: 1.0, // Border width
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dogWalkerData['username'] ?? 'Dog Walker Name not available',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          dogWalkerData['status'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
