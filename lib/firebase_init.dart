import 'package:firebase_core/firebase_core.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBmvtzENCblQzcdtOpwwNAWOI6eFtakUV4",
      appId: "1:231373362222:android:4991c7dc06ac2b9f9d3bbf",
      projectId: "buddy-275ee",
      storageBucket: "buddy-275ee.firebasestorage.app",
      messagingSenderId: "231373362222",
    ),
  );
}
