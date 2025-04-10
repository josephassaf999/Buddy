import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../info page/DW_info_page.dart';

// Dog model class
class Dog {
  final String name;
  final String breed;
  final String age;
  final List<String> imageUrls;
  final String location;
  final String phoneNumber;
  final String description;
  final String ownerId;

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

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Dog> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Search Dogs',
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
              return Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search dogs by name or breed',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            String query = _searchController.text.trim();
                            _performSearch(query);
                          },
                        ),
                      ),
                      onChanged: (value) {
                        String query = value.trim();
                        _performSearch(query);
                      },
                    ),
                  ),
                  // Search Results List
                  Expanded(
                    child: _searchResults.isNotEmpty
                        ? ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (BuildContext context, int index) {
                        final dog = _searchResults[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InfoPage(
                                  name: dog.name,
                                  breed: dog.breed,
                                  age: dog.age,
                                  imageUrls: dog.imageUrls,
                                  location: dog.location,
                                  phone_number: dog.phoneNumber,
                                  description: dog.description,
                                  ownerId: dog.ownerId,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 3.0,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(dog.name),
                              subtitle: Text(dog.location),
                              trailing: Icon(Icons.arrow_forward_ios),
                            ),
                          ),
                        );
                      },
                    )
                        : const Center(
                      child: Text(
                        'No search results',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text('No Dog Owners found'));
            }
          }
        },
      ),
    );
  }
  void _performSearch(String query) {
    List<Dog> filteredDogs = [];

    // Convert query to lowercase for case-insensitive search
    query = query.toLowerCase();

    // Fetch all Dog owner documents
    FirebaseFirestore.instance.collection('Dog owner').get().then((ownersSnapshot) async {
      List<Dog> allDogs = [];

      // Loop through each dog owner
      for (var ownerDoc in ownersSnapshot.docs) {
        // Fetch dogs from each owner's 'dogs' subcollection
        QuerySnapshot dogSnapshot = await ownerDoc.reference.collection('dogs').get();

        // Loop through each dog and check if it matches the query
        dogSnapshot.docs.forEach((doc) {
          // Print document data for debugging
          print("Dog data: ${doc.data()}");

          String dogName = (doc['dog_name'] as String? ?? '').toLowerCase();
          String dogBreed = (doc['breed'] as String? ?? '').toLowerCase();

          // Check if either the name or breed matches the query
          if (dogName.contains(query) || dogBreed.contains(query)) {
            allDogs.add(Dog(
              name: doc['dog_name'] ?? 'No Name',
              breed: doc['breed'] ?? 'Unknown Breed',
              age: doc['age']?.toString() ?? 'Unknown Age',
              imageUrls: List<String>.from(doc['images'] ?? []),
              location: doc['location'] ?? 'Unknown Location',
              phoneNumber: doc['phone_number'] ?? '',
              description: doc['description'] ?? 'No Description',
              ownerId: ownerDoc.id,
            ));
          }
        });
      }

      // Update the search results
      setState(() {
        _searchResults = allDogs;
      });
    }).catchError((e) {
      print('Error fetching dogs: $e');
    });
  }

}
