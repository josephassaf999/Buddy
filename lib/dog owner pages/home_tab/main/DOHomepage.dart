import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddDogPage.dart';
import '../side menu/DogOwnerMessaging.dart';
import 'DogPage.dart';

class DOHomeScreen extends StatefulWidget {
  @override
  _DOHomeScreenState createState() => _DOHomeScreenState();
}

class _DOHomeScreenState extends State<DOHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  List<DocumentSnapshot> ownedDogs = [];

  @override
  void initState() {
    super.initState();
    fetchOwnedDogs();
  }

  Future<void> fetchOwnedDogs() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Dog owner')
        .doc(userId)
        .collection('dogs')
        .get();
    setState(() {
      ownedDogs = querySnapshot.docs;
    });
    print('Fetched ${ownedDogs.length} dogs');
    ownedDogs.forEach((dog) {
      print('Dog: ${dog.data()}');
    });
  }

  void onDogTapped(DocumentSnapshot dog) async {
    DocumentSnapshot dogSnapshot = await dog.reference.get();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyDogScreen(
          dogData: dogSnapshot.data() as Map<String, dynamic>,
          dogId: '', ownerId: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            color: Colors.white,
            onPressed: () {
              _scaffoldKey.currentState!.openEndDrawer();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ownedDogs.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Dogs:',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: ownedDogs.length,
                    itemBuilder: (context, index) {
                      String dogName = ownedDogs[index]['dog_name'];
                      return GestureDetector(
                        onTap: () {
                          onDogTapped(ownedDogs[index]);
                        },
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              dogName,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddDogsScreen()),
                  ).then((value) {
                    if (value != null && value is DocumentSnapshot) {
                      setState(() {
                        ownedDogs.add(value);
                      });
                    }
                  });
                },
                child: Text('Add Dog', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.message, color: Colors.blue),
              title: Text(
                'Messaging',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DOMessaging()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
