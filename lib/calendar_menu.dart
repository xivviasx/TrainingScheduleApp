import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'calendar.dart';

class CalendarMenu extends StatelessWidget {
  const CalendarMenu({Key? key}) : super(key: key);

  void _createNewCalendar(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      //dzięki await czeka na zamknięcie okna dialogowego
      String? calendarName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          TextEditingController textController = TextEditingController();
          return AlertDialog(
            title: Text('Dodaj nowy kalendarz'),
            content: TextField(
                controller: textController,
                decoration: InputDecoration(
                    hintText: "Podaj nazwę kalendarza", fillColor: Colors.blue),
                style: TextStyle(color: Colors.black)),
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

      if (calendarName != null && calendarName.isNotEmpty) {
        DocumentReference newCalendarRef =
            FirebaseFirestore.instance.collection('calendars').doc();
        //zrobienie nowego kalendarza
        await newCalendarRef.set({
          'name': calendarName,
          'owner': user.uid,
        });
        //dodanie dokumentu ownera do kolekcji uzytkowników kalendarza
        await newCalendarRef.collection('participants').doc(user.uid).set({
          'role': 'owner',
        });
        //dodanie kalendarza do kolecji kalendarzy ownera
        DocumentReference userCalendarRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('userCalendars')
            .doc(newCalendarRef.id);
        await userCalendarRef.set({
          'calendarId': newCalendarRef.id,
          'name': calendarName,
          'role': 'owner',
        });
      }
      ;
    }
  }

  void _openCalendar(BuildContext context, String calendarId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Calendar(calendarId: calendarId),
      ),
    );
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
                  _openCalendar(context,
                      calendarId); // Wywołuje funkcję nawigacji po kliknięciu kalendarza
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(calendarName),
                ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FloatingActionButton(
                        onPressed: () => _createNewCalendar(context),
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
