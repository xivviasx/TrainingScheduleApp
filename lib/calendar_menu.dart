import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarMenu extends StatelessWidget {
  const CalendarMenu({Key? key}) : super(key: key);

  void _createNewCalendar(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Pobierz nazwę kalendarza od użytkownika
      String? calendarName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          TextEditingController textController = TextEditingController();
          return AlertDialog(
            title: Text('Nowy kalendarz'),
            content: TextField(
              controller: textController,
              decoration: InputDecoration(hintText: 'Nazwa kalendarza'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(textController.text);
                },
                child: Text('Dodaj'),
              ),
            ],
          );
        },
      );

      // Dodaj nowy kalendarz do Firestore
      if (calendarName != null && calendarName.isNotEmpty) {
        // Utwórz referencję do nowego dokumentu kalendarza
        DocumentReference newCalendarRef =
            FirebaseFirestore.instance.collection('calendars').doc();

        // Dodaj informacje o kalendarzu do Firestore
        await newCalendarRef.set({
          'name': calendarName,
          'owner': user.uid,
        });

        // Dodaj użytkownika jako uczestnika kalendarza
        await newCalendarRef.collection('participants').doc(user.uid).set({
          'role':
              'owner', // Możesz zmienić rolę na 'participant' jeśli to właściwe
        });

        // Dodaj informacje o kalendarzu do kolekcji userCalendars użytkownika
        DocumentReference userCalendarRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('userCalendars')
            .doc(newCalendarRef.id);
        await userCalendarRef.set({
          'calendarId': newCalendarRef.id,
          'name': calendarName,
          'role':
              'owner', // Możesz zmienić rolę na 'participant' jeśli to właściwe
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('userCalendars')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Widget> calendarButtons = [];
          snapshot.data?.docs.forEach((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String calendarId = data['calendarId'];
            String calendarName = data['name'];
            calendarButtons.add(
              ElevatedButton(
                onPressed: () {
                  // Do something when the button is pressed, e.g., navigate to the calendar page
                },
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(calendarName)),
              ),
            );
          });
          return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: calendarButtons,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FloatingActionButton(
                        onPressed: () => _createNewCalendar(context),
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    )
                  ]),
                ],
              ));
        }
      },
    );
  }
}
