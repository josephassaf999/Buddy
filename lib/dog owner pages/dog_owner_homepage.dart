import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class DogOwnerHomepage extends StatefulWidget {
  const DogOwnerHomepage({Key? key}) : super(key: key);

  @override
  _DogOwnerHomePageState createState() => _DogOwnerHomePageState();
}

class _DogOwnerHomePageState extends State<DogOwnerHomepage> {
  int _currentIndex = 0;

  // ✅ Add pages to prevent RangeError
  final List<Widget> _pages = [
    Center(child: Text("Home Page", style: TextStyle(fontSize: 24))),
    Center(child: Text("Account Page", style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: _pages[_currentIndex], // ✅ No more empty list error
        bottomNavigationBar: Container(
          color: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
            child: GNav(
              backgroundColor: Colors.blue,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.blue.shade300,
              gap: 8,
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              padding: const EdgeInsets.all(16),
              tabs: const [
                GButton(icon: Icons.home, text: 'Home'),
                GButton(icon: Icons.person, text: 'Account'),
              ],
            ),
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
            child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  void main() {
    runApp(MaterialApp(
      home: DogOwnerHomepage(),
    ));
  }
}
