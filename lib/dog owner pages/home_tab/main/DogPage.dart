import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyDogScreen extends StatefulWidget {
  final Map<String, dynamic> dogData;
  final String dogId;

  MyDogScreen({
    required this.dogId,
    required this.dogData,
    required String ownerId,
  });

  @override
  State<MyDogScreen> createState() => MyDogScreenState();
}

class MyDogScreenState extends State<MyDogScreen> {
  late Map<String, dynamic> dogDataMap;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> imageUrls = [];
  late String ownerId;
  late String dogId;

  @override
  void initState() {
    super.initState();
    dogDataMap = widget.dogData;

    // Fetch the current user's ID from Firebase Authentication
    ownerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    dogId = widget.dogId.isNotEmpty ? widget.dogId : widget.dogData['dog_id'] ?? '';

    print('🐶 ownerId: $ownerId');
    print('🐶 dogId: $dogId');
    print('🐶 dogData: ${widget.dogData}');

    if (ownerId.isNotEmpty && dogId.isNotEmpty) {
      _loadExistingImages();
    } else {
      print("! ownerId or dogId is empty. Skipping image load.");
    }
  }

  Future<void> _loadExistingImages() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Dog owner')
          .doc(ownerId)
          .collection('dogs')
          .doc(dogId)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          imageUrls = List<String>.from(data['images'] ?? []);
        });
      }
    } catch (e) {
      print("Error loading images: $e");
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _uploadImage(imageFile);
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      String fileName = 'dog_images/$dogId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});

      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("✅ Upload Success: $downloadUrl");

      await _saveImageUrlToFirestore(downloadUrl);

      setState(() {
        imageUrls.insert(0, downloadUrl);
      });
    } catch (e) {
      print("❌ Upload Error: $e");
    }
  }

  Future<void> _saveImageUrlToFirestore(String downloadUrl) async {
    try {
      DocumentReference dogDocRef = FirebaseFirestore.instance
          .collection('Dog owner')
          .doc(ownerId)
          .collection('dogs')
          .doc(dogId);

      await dogDocRef.update({
        'images': FieldValue.arrayUnion([downloadUrl]),
      });

      print("✅ Image URL saved successfully");
    } catch (e) {
      print("❌ Error saving image URL: $e");
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      // Delete from Firebase Storage
      Reference imageRef = _storage.refFromURL(imageUrl);
      await imageRef.delete();
      print("✅ Image deleted from storage");

      // Remove from Firestore
      DocumentReference dogDocRef = FirebaseFirestore.instance
          .collection('Dog owner')
          .doc(ownerId)
          .collection('dogs')
          .doc(dogId);

      await dogDocRef.update({
        'images': FieldValue.arrayRemove([imageUrl]),
      });

      setState(() {
        imageUrls.remove(imageUrl);
      });

      print("✅ Image URL removed from Firestore");
    } catch (e) {
      print("❌ Error deleting image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${dogDataMap['dog_name']}',
          style: TextStyle(fontFamily: "Roboto", color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload Pictures', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),

            GridView.builder(
              itemCount: imageUrls.length + 1,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
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
                                  title: Text('Choose from Gallery', style: TextStyle(fontFamily: "Roboto")),
                                  onTap: () {
                                    _getImage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.camera_alt),
                                  title: Text('Take a Photo', style: TextStyle(fontFamily: "Roboto")),
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
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Icon(Icons.camera_alt, color: Colors.blue)),
                    ),
                  );
                } else {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrls[index - 1],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -10,
                        right: -10,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteImage(imageUrls[index - 1]);
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),

            SizedBox(height: 24),
            Text('Dog Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 16),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.pets, color: Colors.blue),
                    title: Text('Dog Name:', style: TextStyle(fontSize: 16, color: Colors.black)),
                    subtitle: Text('${dogDataMap['dog_name']}', style: TextStyle(fontSize: 16)),
                  ),
                  ListTile(
                    leading: Icon(Icons.description, color: Colors.blue),
                    title: Text('Description:', style: TextStyle(fontSize: 16, color: Colors.black)),
                    subtitle: Text('${dogDataMap['description']}', style: TextStyle(fontSize: 16)),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.blue),
                    title: Text('Location:', style: TextStyle(fontSize: 16, color: Colors.black)),
                    subtitle: Text('${dogDataMap['location']}', style: TextStyle(fontSize: 16)),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone_android, color: Colors.blue),
                    title: Text('Phone Number:', style: TextStyle(fontSize: 16, color: Colors.black)),
                    subtitle: Text('${dogDataMap['phone_number']}', style: TextStyle(fontSize: 16)),
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
