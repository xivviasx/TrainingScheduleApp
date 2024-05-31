import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/calendar_provider.dart';
import 'calendar.dart';

class CalendarMenu extends ConsumerWidget {
  const CalendarMenu({Key? key}) : super(key: key);

  void _openCalendar(BuildContext context, String calendarId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Calendar(calendarId: calendarId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCalendars = ref.watch(userCalendarsProvider);

    return userCalendars.when(
      data: (querySnapshot) {
        List<Widget> calendarButtons = [];
        querySnapshot.docs.forEach((doc) {
          var data = doc.data() as Map<String, dynamic>;
          String calendarId = data['calendarId'];
          String calendarName = data['name'];
          calendarButtons.add(
            ElevatedButton(
              onPressed: () {
                _openCalendar(context, calendarId);
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
                      onPressed: () => _createNewCalendar(context, ref),
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}

void _createNewCalendar(BuildContext context, WidgetRef ref) async {
  final calendarRepository = ref.read(calendarRepositoryProvider);

  if (calendarRepository.isUserLogged() == true) {
    String? calendarName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController textController = TextEditingController();
        return AlertDialog(
          title: Text('Dodaj nowy kalendarz'),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(hintText: "Podaj nazwę kalendarza"),
            style: TextStyle(color: Colors.black),
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

    if (calendarName != null && calendarName.isNotEmpty) {
      await calendarRepository.createNewCalendar(calendarName);
    }
  }
}
