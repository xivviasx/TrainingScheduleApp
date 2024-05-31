import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final userProvider = FutureProvider<User?>((ref) async {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return firebaseAuth.currentUser;
});

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user != null) {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final firstName = userData['firstName'] as String? ?? 'not found';
    final lastName = userData['lastName'] as String? ?? 'not found';
    final email = userData['email'] as String? ?? 'not found';
    return UserProfile(firstName: firstName, lastName: lastName, email: email);
  } else {
    throw Exception("User not logged in");
  }
});
