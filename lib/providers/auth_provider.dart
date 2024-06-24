import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// zmiany w stanie zalogowania (zalogowanie/wylogowanie)
final authChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// zmienne (providery) przechowujące instancje firebaseAuth i firestore
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// authService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref _ref;
  AuthService(this._ref);

  Future<void> signIn(String email, String password) async {
    try {
      await _ref.read(firebaseAuthProvider).signInWithEmailAndPassword(
            email: email,
            password: password,
          );
    } catch (e) {
      rethrow;
    }
    // funkcje asynchroniczne zwracają Future<...>
    // .read => jednorazowe odczytanie, nie nasłuchuje przyszłych zmian
  }

  Future<void> signOut(BuildContext context) async {
    await _ref.read(firebaseAuthProvider).signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> register(
      String email, String password, String firstName, String lastName) async {
    try {
      // tworzenie nowego użytkownika w firebaseAuth
      // UserCredential => zawiera informacje o nowym userze
      UserCredential newUserInfo =
          await _ref.read(firebaseAuthProvider).createUserWithEmailAndPassword(
                email: email,
                password: password,
              );

      //zapisywanie użytkownika w bazie firestore
      await _ref
          .read(firestoreProvider)
          .collection('users')
          .doc(
              newUserInfo.user!.uid) // user! => user na pewno nie będzie nullem
          .set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      });
    } catch (e) {
      rethrow;
    }
  }
}
