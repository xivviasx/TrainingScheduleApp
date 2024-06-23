import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// zmienne (providery) przechowujące firebaseAuth i firestore
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// aktualnie zalogowany użytkownik
final currentUserProvider = FutureProvider<User?>((ref) async {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return firebaseAuth.currentUser;
});

// zmiany w stanie zalogowania (zalogowanie/wylogowanie)
final authChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// authService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref _ref;
  AuthService(this._ref);

  //funkcje asynchroniczne
  Future<void> signIn(String email, String password) async {
    try {
      await _ref.read(firebaseAuthProvider).signInWithEmailAndPassword(
            email: email,
            password: password,
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut(BuildContext context) async {
    await _ref.read(firebaseAuthProvider).signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Future<void> register(
      String email, String password, String firstName, String lastName) async {
    try {
      // tworzenie nowego użytkownika     read => odczytanie aktualnej wartosci
      UserCredential userCredential =
          await _ref.read(firebaseAuthProvider).createUserWithEmailAndPassword(
                email: email,
                password: password,
              );

      //zapisywanie użytkownika w bazie firestore
      await _ref
          .read(firestoreProvider)
          .collection('users')
          .doc(userCredential.user!.uid)
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
