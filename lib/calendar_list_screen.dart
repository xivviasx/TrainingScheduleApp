// tworzenie widoku z listą kalendarzy użytkownika
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/calendar_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calendar_details_screen.dart';

class CalendarListScreen extends ConsumerWidget {
  const CalendarListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarService = ref.watch(calendarServiceProvider);
    return StreamBuilder<QuerySnapshot>(
      // nasłuchuje zmian w kolekcji kalendarzy użytkownika
      stream: calendarService.getUserCalendars(),
      // funkcja budująca
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Nie masz jeszcze kalendarzy'));
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildCalendarButtons(context, snapshot.data!),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FloatingActionButton(
                        onPressed: () => _createNewCalendar(context, ref),
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // budowanie listy przycisków (widgetu) z każdym kalendarzem
  List<Widget> _buildCalendarButtons(
    BuildContext context,
    QuerySnapshot snapshot,
  ) {
    return snapshot.docs.map((document) {
      var data = document.data() as Map<String, dynamic>;
      // klucze (String) => calendarId, name
      // wartośści kluczy (dynamic) => wartości dla calendarId, name
      String calendarId = data['calendarId'];
      String calendarName = data['name'];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.white, // Kolor tła przycisku
            onPrimary: Colors.black, // Kolor tekstu na przycisku
            shadowColor: Colors.grey, // Kolor cienia
            elevation: 3, // Wysokość cienia

            padding: EdgeInsets.symmetric(horizontal: 24),
          ),
          onPressed: () {
            _openCalendar(context, calendarId);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(calendarName),
          ),
        ),
      );
    }).toList();
  }

  // funkcja do tworzenia nowych kalendarzy
  void _createNewCalendar(BuildContext context, WidgetRef ref) async {
    final calendarService = ref.read(calendarServiceProvider);

    if (calendarService.isUserLogged() == true) {
      // okno dialogowe z pobieraniem nazwy kalendarza
      String? calendarName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          // kontroler nazwy nowego kalendarza
          TextEditingController _calendarNameController =
              TextEditingController();
          return AlertDialog(
            title: Text('Utwórz nowy kalendarz'),
            content: TextField(
                controller: _calendarNameController,
                decoration: InputDecoration(
                    hintText: "Podaj nazwę", fillColor: Colors.blue),
                style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(_calendarNameController.text);
                },
                child: Text('Dodaj'),
              ),
            ],
          );
        },
      );

      // tworzenie nowego kalendarza w bazie
      if (calendarName != null && calendarName.isNotEmpty) {
        await calendarService.createNewCalendar(calendarName);
      }
    }
  }

  void _openCalendar(BuildContext context, String calendarId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarDetails(calendarId: calendarId),
      ),
    );
  }
}
