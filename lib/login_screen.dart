import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  // kontrolery
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authChangesProvider);

    // Jesli user jest juz zalogowany to przechodzi od razu do strony domowej
    authState.when(
      data: (user) {
        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });
        }
      },
      loading: () {},
      error: (error, stackTrace) {},
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Login',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Hasło',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: TextStyle(color: Colors.black),
              obscureText: true,
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _login(context, ref);
                },
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                child: Text(
                  'Zaloguj',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Registration button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _register(context, ref);
                },
                style: ElevatedButton.styleFrom(primary: Colors.grey[300]),
                child: Text(
                  'Zarejestruj',
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // metody asynchroniczne
  Future<void> _login(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authServiceProvider);
    try {
      await auth.signIn(
        _emailController.text,
        _passwordController.text,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Spróbuj ponownie'),
        ),
      );
    }
  }

  void _register(BuildContext context, WidgetRef ref) async {
    Navigator.pushNamed(context, '/register');
  }
}
