import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rejestracja'),
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
                  _register(context);
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

  Future<void> _register(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save user details to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': _emailController.text.trim(),
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
      });

      print('Registration successful! User ID: ${userCredential.user!.uid}');
      Navigator.pushReplacementNamed(context, '/');
    } catch (error) {
      print('Registration error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Spróbuj ponownie.'),
        ),
      );
    }
  }
}
