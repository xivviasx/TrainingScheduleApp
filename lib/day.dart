import 'package:Calendar/event_list.dart';
import 'package:flutter/material.dart';
import 'create_event_page.dart';
import 'event_list.dart';

class Day extends StatelessWidget {
  final DateTime selectedDay;
  final String calendarId;

  const Day({Key? key, required this.selectedDay, required this.calendarId})
      : super(key: key);

  void _addEvent(
      BuildContext context, DateTime selectedDay, String calendarId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateEventPage(selectedDay: selectedDay, calendarId: calendarId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16),
        color: Colors.blue[100],
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Treningi dnia:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${selectedDay.day}.${selectedDay.month}.${selectedDay.year}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _addEvent(context, selectedDay, calendarId);
                },
                child: Text(
                  'Dodaj trening',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          EventList(selectedDay: selectedDay, calendarId: calendarId),
        ]));
  }
}
