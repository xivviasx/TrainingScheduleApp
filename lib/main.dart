import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginPage.dart';
import 'homePage.dart';
import 'registerPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDHb4mNThf9SXGoGRlwbB8EMXo8ev0tQSI",
      appId: "1:177822016585:android:6841b4d6350f9814884b98",
      messagingSenderId: "177822016585'",
      projectId: "calendar-a5a4d",
    ),
  );
  FirebaseFirestore.instance;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/home': (context) {
            if (FirebaseAuth.instance.currentUser != null) {
              return HomePage();
            } else {
              return LoginPage();
            }
          },
        },
        theme: ThemeData(
          primaryColor: Colors.blue,
          backgroundColor: Colors.white,
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.white),
          ),
        ),
      );
}
