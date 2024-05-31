import 'package:Calendar/calendar_menu.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Widget bodyWidget = CalendarMenu();

  void _setBodyWidget(Widget widget) {
    setState(() {
      bodyWidget = widget;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

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
                _setBodyWidget(ProfilePage());
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              title: Text('Moje kalendarze'),
              onTap: () {
                _setBodyWidget(CalendarMenu());
                Navigator.pop(context); // Close the drawer
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
}
