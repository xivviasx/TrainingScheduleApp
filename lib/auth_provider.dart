import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final authProvider = Provider<AuthService>((ref) {
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
  }

  Future<void> signOut() async {
    await _ref.read(firebaseAuthProvider).signOut();
  }

  Future<void> register(
      String email, String password, String firstName, String lastName) async {
    try {
      UserCredential userCredential =
          await _ref.read(firebaseAuthProvider).createUserWithEmailAndPassword(
                email: email,
                password: password,
              );

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
