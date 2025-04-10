import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String dogOwnerId;  // The owner userId from Firebase
  final String dogName;

  ChatScreen({required this.dogOwnerId, required this.dogName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  String ownerUsername = ""; // To store the owner's username

  // Fetch the owner's username from the 'Dog owner' collection
  void _fetchOwnerUsername() async {
    try {
      DocumentSnapshot ownerDoc = await FirebaseFirestore.instance
          .collection('Dog owner') // Fetching from the 'Dog owner' collection
          .doc(widget.dogOwnerId) // Get the owner by their ID
          .get();

      if (ownerDoc.exists) {
        setState(() {
          ownerUsername = ownerDoc['username'] ?? "Unknown User"; // Get the username from Firestore
        });
      }
    } catch (error) {
      print("Error fetching owner username: $error");
    }
  }

  // Send message to Firestore
  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String message = _messageController.text;
      String senderId = FirebaseAuth.instance.currentUser?.uid ?? "anonymous";

      // Save message to Firestore under the chat document for this specific user pair
      await FirebaseFirestore.instance.collection('Chats')
          .doc('${senderId}_${widget.dogOwnerId}')
          .collection('messages')
          .add({
        'text': message,
        'senderId': senderId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();  // Clear the input after sending the message
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOwnerUsername(); // Fetch the owner's username when the screen is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData(color: Colors.white),
        title: ownerUsername.isEmpty
            ? Text('Loading...',style: TextStyle(color: Colors.white),) // Show a loading text until the username is fetched
            : Text('Chat with $ownerUsername',style: TextStyle(color: Colors.white),), // Display the owner's username in the AppBar
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Chats')
                  .doc('${FirebaseAuth.instance.currentUser?.uid ?? "anonymous"}_${widget.dogOwnerId}')
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  String messageText = message['text'];
                  String messageSender = message['senderId'];

                  bool isCurrentUser = messageSender == FirebaseAuth.instance.currentUser?.uid;

                  messageWidgets.add(
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Align(
                        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: isCurrentUser ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Text(
                            messageText,
                            style: TextStyle(
                              color: isCurrentUser ? Colors.white : Colors.black,fontSize: 17.5
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return ListView(
                  reverse: true,  // So new messages appear at the bottom
                  children: messageWidgets,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
