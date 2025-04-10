import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DOChatScreen extends StatefulWidget {
  final String senderUserId;
  final String recipientUserId;
  final Map<String, dynamic> recipientUserData;
  final String conversationId;

  const DOChatScreen({
    required this.senderUserId,
    required this.recipientUserId,
    required this.recipientUserData,
    required this.conversationId,
    required Map senderUserData,
  });

  @override
  _DOChatScreenState createState() => _DOChatScreenState();
}

class _DOChatScreenState extends State<DOChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String senderId = widget.senderUserId;
    String recipientId = widget.recipientUserId;
    String conversationId = widget.conversationId;

    try {
      await _firestore.collection('Chats').doc(conversationId).collection('messages').add({
        'text': _messageController.text,
        'senderId': senderId,
        'recipientId': recipientId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String senderId = widget.senderUserId;
    String conversationId = widget.conversationId;

    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData(color: Colors.white),
        title: Text('${widget.recipientUserData['username']}',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('Chats')
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
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data['text'],
                          style: TextStyle(color: isMe ? Colors.white : Colors.white,fontSize: 17.5),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical:5 ,horizontal:20),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
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
