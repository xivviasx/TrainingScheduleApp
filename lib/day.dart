import 'package:flutter/material.dart';
import 'package:Calendar/event_list.dart';
import 'create_event_page.dart';

class Day extends StatelessWidget {
  final DateTime selectedDay;
  final String calendarId;

  const Day({Key? key, required this.selectedDay, required this.calendarId})
      : super(key: key);

  void _addEvent(BuildContext context) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${selectedDay.day}.${selectedDay.month}.${selectedDay.year}',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child:
                  EventList(selectedDay: selectedDay, calendarId: calendarId),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _addEvent(context);
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(Icons.add, color: Colors.white),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
