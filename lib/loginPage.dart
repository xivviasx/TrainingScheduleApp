import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email text field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                labelStyle:
                    TextStyle(color: Colors.black), // Set label text color
              ),
              style: TextStyle(color: Colors.black), // Set input text color
            ),
            SizedBox(height: 16), // Spacer
            // Password text field
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                labelStyle:
                    TextStyle(color: Colors.black), // Set label text color
              ),
              style: TextStyle(color: Colors.black), // Set input text color
              obscureText: true,
            ),
            SizedBox(height: 16), // Spacer
            // Log in button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Call the login method when the button is pressed
                  _login(context);
                },
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context)
                        .primaryColor), // Set button background color
                child: Text(
                  'Log in',
                  style:
                      TextStyle(color: Colors.white), // Set button text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to handle the login process
  Future<void> _login(BuildContext context) async {
    try {
      // Sign in with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If login is successful, navigate to the next screen or perform other actions
      // For now, let's print a success message
      print('Login successful! User ID: ');
      Navigator.pushNamed(context, '/home');
    } catch (error) {
      // Handle login errors
      print('Login error: $error');
      // Show a snackbar or dialog to inform the user about the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed. Please try again.'),
        ),
      );
    }
  }
}
