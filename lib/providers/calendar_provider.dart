import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';

// Firestore operations provider for Calendar
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final firestore = ref.read(firestoreProvider);
  final firebaseAuth = ref.read(firebaseAuthProvider);
  return CalendarRepository(firestore, firebaseAuth);
});

class CalendarRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CalendarRepository(this._firestore, this._firebaseAuth);

  bool isUserLogged() {
    User? user = _firebaseAuth.currentUser;
    return user != null;
  }

  Stream<QuerySnapshot> getUserCalendars() {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('userCalendars')
          .snapshots();
    } else {
      throw Exception("No user logged in");
    }
  }

  Future<void> createNewCalendar(String calendarName) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      DocumentReference newCalendarRef =
          _firestore.collection('calendars').doc();
      await newCalendarRef.set({'name': calendarName, 'owner': user.uid});
      await newCalendarRef
          .collection('participants')
          .doc(user.uid)
          .set({'role': 'owner'});
      DocumentReference userCalendarRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('userCalendars')
          .doc(newCalendarRef.id);
      await userCalendarRef.set({
        'calendarId': newCalendarRef.id,
        'name': calendarName,
        'role': 'owner'
      });
    }
  }

  Stream<QuerySnapshot> getEventsForDay(
      String calendarId, DateTime selectedDay) {
    DateTime startOfDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 0, 0, 0);
    DateTime endOfDay = DateTime(
        selectedDay.year, selectedDay.month, selectedDay.day, 23, 59, 59);

    String formattedDate =
        '${selectedDay.year}-${selectedDay.month}-${selectedDay.day}';

    return _firestore
        .collection('calendars')
        .doc(calendarId)
        .collection('events')
        .doc(formattedDate)
        .collection('dayEvents')
        .snapshots();
  }
}
