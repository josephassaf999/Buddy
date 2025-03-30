import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../search tab/info page/DW_info_page.dart';

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
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('Dogs').get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<InfoPage> dogs = [];

            // If there are documents in Firestore, process them, otherwise, keep an empty list
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              dogs = snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                return InfoPage(
                  item: data['name'],
                  breed: data['breed'],
                  age: data['age'],
                  imageUrls: List<String>.from(data['imageUrls']),
                  location: 'Placeholder Location',
                );
              }).toList();
            }

            // If no data in Firestore, show a few placeholder items
            if (dogs.isEmpty) {
              dogs = List.generate(4, (index) {
                return InfoPage(
                  item: 'Placeholder Dog ${index + 1}',
                  breed: 'Breed: ',
                  imageUrls: ['assets/placeholder_image.jpg'],
                  age: 'age: ',
                  location: 'Placeholder Location', // Use a local placeholder image
                );
              });
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dogs Available for Walking',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Grid View with placeholder or real dog data
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                item: dogs[index].item,
                                breed: dogs[index].breed,
                                age: dogs[index].age.toString(),
                                imageUrls: dogs[index].imageUrls, location: '',
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
          }
        },
      ),
    );
  }
}

class DogWidget extends StatelessWidget {
  final InfoPage dog;
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
                child: Image.asset(
                  dog.imageUrls.isNotEmpty ? dog.imageUrls.first : 'assets/placeholder_image.jpg', // Use a placeholder image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                dog.item,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${dog.breed}, ${dog.age} years old',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
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


