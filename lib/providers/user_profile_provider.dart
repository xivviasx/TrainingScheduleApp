import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
  });
}

final userProfileProvider = StreamProvider<UserProfile>((ref) {
  final _firebaseAuth = ref.watch(firebaseAuthProvider);
  final _firestore = ref.watch(firestoreProvider);

  return _firebaseAuth.authStateChanges().asyncMap((user) async {
    if (user != null) {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      final firstName = userData.get('firstName') as String? ?? 'brak';
      final lastName = userData.get('lastName') as String? ?? 'brak';
      final email = userData.get('email') as String? ?? 'brak';
      return UserProfile(
          firstName: firstName, lastName: lastName, email: email);
    } else {
      throw Exception("Użytkownik nie jest zalogowany");
    }
  });
});
