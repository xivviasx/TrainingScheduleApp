import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';

final calendarServiceProvider = Provider<CalendarService>((ref) {
  final _firestore = ref.read(firestoreProvider);
  final _firebaseAuth = ref.read(firebaseAuthProvider);
  //final _currentUser = ref.watch(currentUserProvider);
  //return CalendarService(_firestore, _firebaseAuth, _currentUser.value);
  return CalendarService(_firestore, _firebaseAuth);
});

class CalendarService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  //final User? _currentUser;
  User? get _currentUser => _firebaseAuth.currentUser;

  //CalendarService(this._firestore, this._firebaseAuth, this._currentUser);
  CalendarService(this._firestore, this._firebaseAuth);

  bool isUserLogged() {
    return _currentUser != null;
  }

  Stream<QuerySnapshot> getUserCalendars() {
    if (_currentUser != null) {
      return _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('userCalendars')
          .snapshots();
    } else {
      throw Exception("Użytkonik nie jest zalogowany");
    }
  } // zwraca listę dokumentów

  Future<void> createNewCalendar(String calendarName) async {
    if (_currentUser != null) {
      // generowanie nowego pustego dokumentu z id
      DocumentReference newCalendarRef =
          _firestore.collection('calendars').doc();

      // wypełnianie nowego dokumentu
      await newCalendarRef
          .set({'name': calendarName, 'owner': _currentUser!.uid});
      await newCalendarRef
          .collection('participants')
          .doc(_currentUser!.uid)
          .set({'role': 'owner'});
      // przypisywanie ownerowi kalendarza
      DocumentReference userCalendarRef = _firestore
          .collection('users')
          .doc(_currentUser!.uid)
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
        throw Exception("Nie ma kalendrza o takiej nazwie");
      }
    } else {
      throw Exception("Nie znaleziono kalendarza");
    }
  }

  Stream<QuerySnapshot> getEventsForDay(
      String calendarId, DateTime selectedDay) {
    String date = '${selectedDay.year}-${selectedDay.month}-${selectedDay.day}';
    return _firestore
        .collection('calendars')
        .doc(calendarId)
        .collection('events')
        .doc(date)
        .collection('dayEvents')
        .snapshots();
  }

  Future<void> deleteEvent(
      String calendarId, String eventId, DateTime selectedDay) async {
    if (_currentUser != null) {
      String date =
          '${selectedDay.year}-${selectedDay.month}-${selectedDay.day}';
      await _firestore
          .collection('calendars')
          .doc(calendarId)
          .collection('events')
          .doc(date)
          .collection('dayEvents')
          .doc(eventId)
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
      // lista dokumentów (userów)
      List<Map<String, String>> usersInfo = [];
      for (DocumentSnapshot doc in snapshot.docs) {
        String userId = doc.id;
        // wyszukiwanie userów o podanym ID
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
    // wyszukiwanie userów na podstawie email
    QuerySnapshot newParticipants = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    // gdy ktoś próbuje dodać nieistniejącego usera
    if (newParticipants.docs.isEmpty) {
      throw Exception("Nie znaleziono użytkownika");
    }

    // pobieranie Id pierwszego wyszukanego usera
    DocumentSnapshot newParticipantDoc = newParticipants.docs.first;
    String newParticipantId = newParticipantDoc.id;

    // wyszukiwanie kalendarza an podstawie jego id
    DocumentReference calendar =
        _firestore.collection('calendars').doc(calendarId);
    // wyszukiwanie kalendarza w kalendarzach usera
    DocumentReference userCalendar = _firestore
        .collection('users')
        .doc(newParticipantId)
        .collection('userCalendars')
        .doc(calendarId);

    var calendarData = await calendar.get();
    var calendarName =
        (calendarData.data() as Map<String, dynamic>?)?['name'] ?? '';

    await calendar
        .collection('participants')
        .doc(newParticipantId)
        .set({'role': 'participant'});
    await userCalendar.set({
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
    if (_currentUser != null) {
      String date =
          '${selectedDay.year}-${selectedDay.month}-${selectedDay.day}';

      CollectionReference eventsCollection = _firestore
          .collection('calendars')
          .doc(calendarId)
          .collection('events')
          .doc(date)
          .collection('dayEvents');

      await eventsCollection.add({
        'name': eventName,
        'start_time': Timestamp.fromDate(startTime),
        'end_time': Timestamp.fromDate(endTime),
        'created_by': _currentUser!.uid,
        'event_type': eventType,
      });
    }
  }

  Stream<List<DateTime>> getEventsForDayAsDateTimeList(
      String calendarId, DateTime selectedDay) {
    String date = '${selectedDay.year}-${selectedDay.month}-${selectedDay.day}';

    return FirebaseFirestore.instance
        .collection('calendars')
        .doc(calendarId)
        .collection('events')
        .doc(date)
        .collection('dayEvents')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // w każdym doukmencie zmieniamy start_time na DateTime
        Timestamp timestamp = doc.get('start_time');
        return timestamp.toDate();
      }).toList();
    });
  } // funkcja zwraca listę godzin, w których zaczęło się wydarzenie
}
