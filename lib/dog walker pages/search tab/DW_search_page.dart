import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'info page/DW_info_page.dart';

// Dog class
class Dog {
  final String name;
  final String location;
  final String description;
  final List<String> imageUrls;
  final String phone_number;
  final String breed;
  final String age;

  Dog({
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrls,
    required this.phone_number,
    required this.breed,
    required this.age,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();

  // Perform search for dogs in Firestore
  void _performSearch(String query) {
    // Clear previous search results
    _searchResults.clear();

    // Search Firestore for dogs
    FirebaseFirestore.instance
        .collection('Dogs') // Ensure it's the 'Dogs' collection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        _searchResults = querySnapshot.docs
            .map((doc) => Dog(
          name: doc['name'] as String,
          location: doc['location'] as String,
          description: doc['description'] as String,
          imageUrls: List<String>.from(doc['imageUrls']),
          phone_number: doc['phone_number'],
          breed: doc['breed'],
          age: doc['age'],
        ))
            .toList();
      });
    });
  }

  // Correct the type to List<Dog>
  List<Dog> _searchResults = [];

  // Navigate to the InfoPage for the selected dog
  void _navigateToInfoPage(BuildContext context, Dog dog) async {
    List<String> imageUrls = await _getImageUrlsForItem(dog.name);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoPage(
          name: dog.name,
          location: dog.location,
          imageUrls: imageUrls,
          breed: dog.breed,
          age: dog.age,
          phone_number: dog.phone_number,
          description: dog.description,
        ),
      ),
    );
  }

  // Fetch additional image URLs for a specific dog
  Future<List<String>> _getImageUrlsForItem(String itemName) async {
    List<String> assetPaths = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Dogs') // Ensure it's the 'Dogs' collection
          .where('name', isEqualTo: itemName)
          .get();

      querySnapshot.docs.forEach((doc) {
        if (doc.exists) {
          List<dynamic> urls = doc['imageUrls'];
          assetPaths.addAll(urls.map((url) => "$url"));
        }
      });
    } catch (error) {
      print("Error fetching image URLs: $error");
    }

    return assetPaths;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Dogs',  // Change the title to 'Search Dogs'
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue, // Set app bar color to black
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search dogs by name or breed',  // Change hint text
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
            const SizedBox(height: 16.0),
            Expanded(
              child: _searchResults.isNotEmpty
                  ? ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (BuildContext context, int index) {
                  final dog = _searchResults[index];
                  return GestureDetector(
                    onTap: () {
                      _navigateToInfoPage(context, dog);
                    },
                    child: Card(
                      elevation: 3.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          dog.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(dog.location),
                        trailing: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text(
                  'No search results',  // Update the message to 'No search results'
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
