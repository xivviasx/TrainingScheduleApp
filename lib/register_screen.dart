import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';

class RegisterScreen extends ConsumerWidget {
  // kontrolery formularzu rejestracji
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rejestracja', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Login'),
            SizedBox(height: 5),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(border: OutlineInputBorder()),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 16),
            Text('Hasło'),
            SizedBox(height: 5),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(border: OutlineInputBorder()),
              style: TextStyle(color: Colors.black),
              obscureText: true,
            ),
            SizedBox(height: 16),
            Text('Imię'),
            SizedBox(height: 5),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(border: OutlineInputBorder()),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 16),
            Text('Nazwisko'),
            SizedBox(height: 5),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(border: OutlineInputBorder()),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _register(context, ref);
                },
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor),
                child: Text(
                  'Zarejestruj',
                  style: TextStyle(color: Colors.grey[300]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authServiceProvider);
    try {
      await auth.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wystąpił błąd, spróbuj ponownie'),
        ),
      );
    }
  }
}
