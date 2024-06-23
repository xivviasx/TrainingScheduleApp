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

// Provider do pobierania aktualnie zalogowanego użytkownika
final userProvider = FutureProvider<User?>((ref) async {
  final user = ref.watch(currentUserProvider.future);
  return user;
});

// Provider do pobierania danych usera
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user != null) {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final firstName = userData['firstName'] as String? ?? 'brak';
    final lastName = userData['lastName'] as String? ?? 'brak';
    final email = userData['email'] as String? ?? 'brak';
    return UserProfile(firstName: firstName, lastName: lastName, email: email);
  } else {
    throw Exception("Użytkownik nie jest zalogowany");
  }
});
