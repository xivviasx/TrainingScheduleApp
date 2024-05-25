import 'package:Calendar/calendar_menu.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profilePage.dart';
import 'calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    Widget bodyWidget = CalendarMenu();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kalendarz',
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
                bodyWidget = ProfilePage();
                Navigator.pop(context); // Zamyka drawer
              },
            ),
            ListTile(
              title: Text('Moje kalendarze'),
              onTap: () {
                {
                  bodyWidget = ProfilePage();
                  Navigator.pop(context); // Zamyka drawer
                }
              },
            ),
            ListTile(
              title: Text('Wyloguj'),
              onTap: () {
                _logout(context, ref);
              },
            ),
          ],
        ),
      ),
      body: bodyWidget,
    );
  }
}

Future<void> _logout(BuildContext context, WidgetRef ref) async {
  final auth = ref.read(authProvider);
  try {
    auth.signOut(context);
  } catch (error) {
    print('Login error: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nie udało się wylogować'),
      ),
    );
  }
}
