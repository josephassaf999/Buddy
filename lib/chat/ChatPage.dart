import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DWChatScreen extends StatefulWidget {
  final String dogOwnerId;
  final String dogName;

  DWChatScreen({required this.dogOwnerId, required this.dogName});

  @override
  _DWChatScreenState createState() => _DWChatScreenState();
}

class _DWChatScreenState extends State<DWChatScreen> {
  TextEditingController _messageController = TextEditingController();
  String ownerUsername = "";

  String generateConversationId(String id1, String id2) {
    return id1.compareTo(id2) < 0 ? '$id1-$id2' : '$id2-$id1';
  }

  void _fetchOwnerUsername() async {
    try {
      DocumentSnapshot ownerDoc = await FirebaseFirestore.instance
          .collection('Dog owner')
          .doc(widget.dogOwnerId)
          .get();

      if (ownerDoc.exists) {
        setState(() {
          ownerUsername = ownerDoc['username'] ?? "Unknown User";
        });
      }
    } catch (error) {
      print("Error fetching owner username: $error");
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String message = _messageController.text;
      String senderId = FirebaseAuth.instance.currentUser?.uid ?? "anonymous";
      String recipientId = widget.dogOwnerId;
      String conversationId = generateConversationId(senderId, recipientId);

      try {
        await FirebaseFirestore.instance.collection('Chats')
            .doc(conversationId)
            .collection('messages')
            .add({
          'text': message,
          'senderId': senderId,
          'recipientId': recipientId,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _messageController.clear();
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOwnerUsername();
  }

  @override
  Widget build(BuildContext context) {
    String senderId = FirebaseAuth.instance.currentUser?.uid ?? '';
    String conversationId = generateConversationId(senderId, widget.dogOwnerId);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('$ownerUsername', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Chats')
                  .doc(conversationId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                List<Widget> messageWidgets = messages.map((message) {
                  String messageText = message['text'];
                  String messageSender = message['senderId'];

                  bool isCurrentUser = messageSender == senderId;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.blue : Colors.green,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          messageText,
                          style: TextStyle(color: Colors.white, fontSize: 17.5),
                        ),
                      ),
                    ),
                  );
                }).toList();

                return ListView(
                  reverse: true,
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(hintText: "Type a message..."),
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