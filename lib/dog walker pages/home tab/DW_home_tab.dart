import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../info page/DW_info_page.dart';

class DWHomeScreen extends StatelessWidget {
  DWHomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('Dog owner').get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return FutureBuilder<List<Dog>>(
                future: _getDogsFromOwners(snapshot.data!.docs),
                builder: (BuildContext context, AsyncSnapshot<List<Dog>> dogsSnapshot) {
                  if (dogsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (dogsSnapshot.hasError) {
                    return Center(child: Text('Error: ${dogsSnapshot.error}'));
                  } else if (dogsSnapshot.hasData && dogsSnapshot.data!.isNotEmpty) {
                    List<Dog> dogs = dogsSnapshot.data!;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dogs Available for Walking',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16.0,
                              crossAxisSpacing: 16.0,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: dogs.length,
                            itemBuilder: (BuildContext context, int index) {
                              return DogWidget(
                                dog: dogs[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InfoPage(
                                        name: dogs[index].name,
                                        breed: dogs[index].breed,
                                        age: dogs[index].age,
                                        imageUrls: dogs[index].imageUrls,
                                        location: dogs[index].location,
                                        phone_number: dogs[index].phoneNumber,
                                        description: dogs[index].description,
                                        ownerId: dogs[index].ownerId, // 👈 Pass owner ID
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: Text('No dogs available'));
                  }
                },
              );
            } else {
              return const Center(child: Text('No Dog Owners found'));
            }
          }
        },
      ),
    );
  }

  Future<List<Dog>> _getDogsFromOwners(List<DocumentSnapshot> ownerDocs) async {
    List<Dog> dogs = [];

    for (var ownerDoc in ownerDocs) {
      var dogSnapshot = await FirebaseFirestore.instance
          .collection('Dog owner')
          .doc(ownerDoc.id)
          .collection('dogs')
          .get();

      for (var dogDoc in dogSnapshot.docs) {
        Map<String, dynamic> dogData = dogDoc.data() as Map<String, dynamic>;

        String name = dogData['dog_name'] ?? '';
        String breed = dogData['breed'] ?? '';
        String age = dogData['age']?.toString() ?? '';
        List<String> imageUrls = List<String>.from(dogData['images'] ?? []);
        String location = dogData['location'] ?? '';
        String phoneNumber = dogData['phone_number'] ?? '';
        String description = dogData['description'] ?? '';

        dogs.add(Dog(
          name: name,
          breed: breed,
          age: age,
          imageUrls: imageUrls,
          location: location,
          phoneNumber: phoneNumber,
          description: description,
          ownerId: ownerDoc.id, // 👈 Store owner ID here
        ));
      }
    }

    return dogs;
  }
}

class DogWidget extends StatelessWidget {
  final Dog dog;
  final VoidCallback onTap;

  const DogWidget({
    Key? key,
    required this.dog,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: dog.imageUrls.isNotEmpty
                    ? Image.network(
                  dog.imageUrls.first,
                  fit: BoxFit.cover,
                )
                    : const Placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                dog.name.isNotEmpty ? dog.name : 'No Name',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dog model class
class Dog {
  final String name;
  final String breed;
  final String age;
  final List<String> imageUrls;
  final String location;
  final String phoneNumber;
  final String description;
  final String ownerId; // 👈 Owner recognition

  Dog({
    required this.name,
    required this.breed,
    required this.age,
    required this.imageUrls,
    required this.location,
    required this.phoneNumber,
    required this.description,
    required this.ownerId,
  });
}
