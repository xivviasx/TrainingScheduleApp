import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';

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

  Future<String> getCalendarName(String calendarId) async {
    DocumentSnapshot doc =
        await _firestore.collection('calendars').doc(calendarId).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('name')) {
        return data['name'] as String;
      } else {
        throw Exception("Calendar name not found");
      }
    } else {
      throw Exception("Calendar not found");
    }
  }

  Future<void> addParticipantByEmail(String calendarId, String email) async {
    // Find the user by email
    QuerySnapshot userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception("User not found");
    }

    DocumentSnapshot userDoc = userQuery.docs.first;
    String userId = userDoc.id;

    DocumentReference calendarRef =
        _firestore.collection('calendars').doc(calendarId);
    DocumentReference userRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('userCalendars')
        .doc(calendarId);

    var calendarData = await calendarRef.get();
    var calendarName =
        (calendarData.data() as Map<String, dynamic>?)?['name'] ?? '';

    await calendarRef
        .collection('participants')
        .doc(userId)
        .set({'role': 'participant'});
    await userRef.set({
      'calendarId': calendarId,
      'name': calendarName,
      'role': 'participant'
    });
  }

  Stream<List<String>> getCalendarMembersNames(String calendarId) {
    return _firestore
        .collection('calendars')
        .doc(calendarId)
        .collection('participants')
        .snapshots()
        .asyncMap((snapshot) async {
      List<String> names = [];
      for (DocumentSnapshot doc in snapshot.docs) {
        String userId = doc.id;
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          String? userEmail = userDoc.get('email');
          if (userEmail != null) {
            names.add(userEmail);
          }
        }
      }
      return names;
    });
  }
}
