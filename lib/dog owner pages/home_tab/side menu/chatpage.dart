import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String senderUserId;
  final String recipientUserId;
  final Map<String, dynamic> recipientUserData; // Data of the recipient (e.g. name, status)
  final Map<String, dynamic> senderUserData; // Data of the sender (optional)
  final String conversationId;

  const ChatScreen({
    required this.senderUserId,
    required this.recipientUserId,
    required this.recipientUserData,
    required this.senderUserData,
    required this.conversationId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to send the message to Firestore
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String senderId = widget.senderUserId;
    String conversationId = widget.conversationId;

    // Check if conversationId is valid
    if (conversationId.isEmpty) {
      print("Error: conversationId is empty");
      return;  // Return early if conversationId is invalid
    }

    try {
      // Creating the chats collection and the conversation document dynamically
      await _firestore.collection('chats').doc(conversationId).set({
        'senderId': senderId,
        'recipientId': widget.recipientUserId,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge to avoid overwriting data

      await _firestore.collection('chats').doc(conversationId).collection('messages').add({
        'text': _messageController.text,
        'senderId': senderId,
        'recipientId': widget.recipientUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the input field after sending the message
      _messageController.clear();
    } catch (e) {
      print("Error sending message: $e");
      // Optionally, show an alert or some UI feedback here.
    }
  }

  @override
  Widget build(BuildContext context) {
    String senderId = widget.senderUserId;
    String recipientId = widget.recipientUserId;
    String conversationId = widget.conversationId;

    // Validate the conversationId
    if (conversationId.isEmpty) {
      return Scaffold(
        appBar: AppBar(iconTheme:IconThemeData(color: Colors.white),
          title: Text("Error",style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Text("Conversation ID is missing or invalid.", style: TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientUserData['username']),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('chats')
                  .doc(conversationId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                return ListView(
                  reverse: true,
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    bool isMe = data['senderId'] == senderId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.black : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data['text'],
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.black),
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
