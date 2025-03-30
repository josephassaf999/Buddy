import 'package:buddy/dog%20walker%20pages/search%20tab/DW_search_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'account tab/DW_account_page.dart';
import 'home tab/DW_home_tab.dart';

void main() {
  runApp(MaterialApp(
    home: DogWalkerHomepage(),
  ));
}

class DogWalkerHomepage extends StatefulWidget {
  const DogWalkerHomepage({Key? key}) : super(key: key);

  @override
  _DogWalkerHomepageState createState() => _DogWalkerHomepageState();
}

class _DogWalkerHomepageState extends State<DogWalkerHomepage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DWHomeScreen(),
    SearchScreen(),
    DWAccountScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.black,
            gap: 10,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.search,
                text: 'Search',
              ),

              GButton(
                icon: Icons.person,
                text: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Exit',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }
}
