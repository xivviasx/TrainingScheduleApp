import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profilePage.dart';
import 'calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget bodyWidget = Calendar();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('Profil'),
              onTap: () {
                setState(() {
                  bodyWidget = ProfilePage();
                });
                Navigator.pop(context); // Zamyka drawer
              },
            ),
            ListTile(
              title: Text('Moje kalendarze'),
              onTap: () {
                setState(() {
                  bodyWidget = Calendar();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Wyloguj'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: bodyWidget,
    );
  }
}
