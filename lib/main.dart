import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBFeNpPCFKfvegtzwGGrkHh0fs08CALsIw",
      appId: "1:637965316799:android:a94955b38d4abb49ad4c0a",
      messagingSenderId: "637965316799",
      projectId: "beritaku-32bd2",
      storageBucket: "beritaku-32bd2.appspot.com",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeritaKu',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}
