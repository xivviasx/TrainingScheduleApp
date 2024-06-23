import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';

final calendarServiceProvider = Provider<CalendarService>((ref) {
  final firestore = ref.read(firestoreProvider);
  final firebaseAuth = ref.read(firebaseAuthProvider);
  return CalendarService(firestore, firebaseAuth);
});

class CalendarService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CalendarService(this._firestore, this._firebaseAuth);

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
      throw Exception("Użytkonik nie jest zalogowany");
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

  Future<String> getCalendarName(String calendarId) async {
    DocumentSnapshot doc =
        await _firestore.collection('calendars').doc(calendarId).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('name')) {
        return data['name'] as String;
      } else {
        throw Exception("Nie ma kalendaeza o takiej nazwie");
      }
    } else {
      throw Exception("Nie znaleziono kalendarza");
    }
  }

  Stream<QuerySnapshot> getEventsForDay(
      String calendarId, DateTime selectedDay) {
    DateTime startOfDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 0, 0, 0);
    DateTime endOfDay = DateTime(
        selectedDay.year, selectedDay.month, selectedDay.day, 23, 59, 59);

    String Date = '${selectedDay.year}-${selectedDay.month}-${selectedDay.day}';

    return _firestore
        .collection('calendars')
        .doc(calendarId)
        .collection('events')
        .doc(Date)
        .collection('dayEvents')
        .snapshots();
  }

  Future<void> deleteEvent(
      String calendarId, String eventId, DateTime selectedDay) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      String dateString =
          '${selectedDay.year}-${selectedDay.month}-${selectedDay.day}';
      await _firestore
          .collection('calendars')
          .doc(calendarId)
          .collection('events')
          .doc(dateString) // Dokument dla danego dnia
          .collection('dayEvents')
          .doc(eventId) // Dokument wydarzenia
          .delete();
    }
  }

  Stream<List<Map<String, String>>> getCalendarMembersInfo(String calendarId) {
    return _firestore
        .collection('calendars')
        .doc(calendarId)
        .collection('participants')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, String>> usersInfo = [];
      for (DocumentSnapshot doc in snapshot.docs) {
        String userId = doc.id;
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          String? firstName = userDoc.get('firstName');
          String? lastName = userDoc.get('lastName');
          String? email = userDoc.get('email');
          if (firstName != null && lastName != null && email != null) {
            usersInfo.add({
              'firstName': firstName,
              'lastName': lastName,
              'email': email,
            });
          }
        }
      }
      return usersInfo;
    });
  }

  Future<void> addParticipantByEmail(String calendarId, String email) async {
    // wyszukiwanie usera na podstawie id
    QuerySnapshot userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    // gdy ktoś próbuje dodać nieistniejącego usera
    if (userQuery.docs.isEmpty) {
      throw Exception("Nie znaleziono użytkownika");
    }

    // pobieranie Id wyszukanego usera
    DocumentSnapshot userDoc = userQuery.docs.first;
    String userId = userDoc.id;

    // wyszukiwanie kalendarza an podstawie jego id
    DocumentReference calendar =
        _firestore.collection('calendars').doc(calendarId);
    // wyszukiwanie kalendarzy usera
    DocumentReference userCalendars = _firestore
        .collection('users')
        .doc(userId)
        .collection('userCalendars')
        .doc(calendarId);

    var calendarData = await calendar.get();
    var calendarName =
        (calendarData.data() as Map<String, dynamic>?)?['name'] ?? '';

    await calendar
        .collection('participants')
        .doc(userId)
        .set({'role': 'participant'});
    await userCalendars.set({
      'calendarId': calendarId,
      'name': calendarName,
      'role': 'participant'
    });
  }

  Future<void> removeParticipantByEmail(String calendarId, String email) async {
    try {
      // Wyszukanie użytkownika na podstawie adresu e-mail
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception("Nie znaleziono użytkownika");
      }

      // Pobranie ID użytkownika
      DocumentSnapshot userDoc = userQuery.docs.first;
      String userId = userDoc.id;

      // Usunięcie uczestnika z kalendarza
      DocumentReference calendarRef =
          _firestore.collection('calendars').doc(calendarId);
      await calendarRef.collection('participants').doc(userId).delete();

      // Usunięcie kalendarza z kalendarzy użytkownika
      DocumentReference userCalendarRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('userCalendars')
          .doc(calendarId);
      await userCalendarRef.delete();
    } catch (e) {
      throw Exception("Nie udało się usunąć uczestnika");
    }
  }

  Future<void> addEvent(
      String calendarId,
      DateTime selectedDay,
      String eventName,
      DateTime startTime,
      DateTime endTime,
      String eventType) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      String formattedDate =
          '${selectedDay.year}-${selectedDay.month}-${selectedDay.day}';

      CollectionReference eventsCollection = _firestore
          .collection('calendars')
          .doc(calendarId)
          .collection('events')
          .doc(formattedDate)
          .collection('dayEvents');

      await eventsCollection.add({
        'name': eventName,
        'start_time': Timestamp.fromDate(startTime),
        'end_time': Timestamp.fromDate(endTime),
        'created_by': user.uid,
        'event_type': eventType, // Dodanie informacji o typie wydarzenia
      });
    }
  }

  Stream<List<DateTime>> getEventsForDayAsDateTimeList(
      String calendarId, DateTime selectedDay) {
    String dateString =
        '${selectedDay.year}-${selectedDay.month}-${selectedDay.day}';

    return FirebaseFirestore.instance
        .collection('calendars')
        .doc(calendarId)
        .collection('events')
        .doc(dateString)
        .collection('dayEvents')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Timestamp timestamp =
            doc.get('start_time'); // Assuming 'start_time' is a Timestamp
        return timestamp.toDate();
      }).toList();
    });
  }
}
