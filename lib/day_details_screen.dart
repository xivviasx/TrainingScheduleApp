import 'package:flutter/material.dart';
import 'package:Calendar/event_list.dart';
import 'package:intl/intl.dart';
import 'create_event_screen.dart';
import 'chart_screen.dart';

class DayDetailsScreen extends StatelessWidget {
  final DateTime selectedDay;
  final String calendarId;

  const DayDetailsScreen(
      {Key? key, required this.selectedDay, required this.calendarId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // wyświetlanie nazwy miesiąca zamiast cyfry
    String monthName = DateFormat.MMMM().format(selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${selectedDay.day} $monthName ${selectedDay.year}',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.area_chart_sharp),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChartScreen(
                    selectedDay: selectedDay,
                    calendarId: calendarId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child:
                  // lista eventów dnia
                  EventList(selectedDay: selectedDay, calendarId: calendarId),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _addEvent(context, selectedDay, calendarId);
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _addEvent(BuildContext context, selectedDay, calendarId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          CreateEventScreen(selectedDay: selectedDay, calendarId: calendarId),
    ),
  );
}
