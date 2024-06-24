import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'calendar_list_screen.dart';
import 'user_profile_screen.dart';
import 'providers/auth_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  Widget bodyWidget = CalendarListScreen();

  @override
  Widget build(BuildContext context) {
    final authStateService = ref.watch(authChangesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CalendarApp',
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
                _setBodyWidget(UserProfileScreen());
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              title: Text('Moje kalendarze'),
              onTap: () {
                _setBodyWidget(CalendarListScreen());
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
    final auth = ref.read(authServiceProvider);
    try {
      await auth.signOut(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nie udało się wylogować'),
        ),
      );
    }
  }

  void _setBodyWidget(Widget widget) {
    setState(() {
      bodyWidget = widget;
    });
  }
}
