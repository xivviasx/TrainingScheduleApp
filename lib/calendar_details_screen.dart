import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'day_details_screen.dart';
import 'participants_screen.dart';
import 'providers/calendar_provider.dart';

class CalendarDetails extends ConsumerWidget {
  final String calendarId;

  const CalendarDetails({Key? key, required this.calendarId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarService = ref.watch(calendarServiceProvider);

    return Scaffold(
      appBar: AppBar(
        // pobieranie nazwy kalendarza
        title: FutureBuilder<String>(
          future: calendarService.getCalendarName(calendarId),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ??
                  'Kalendarz', // nazwa kalendarza lub napis 'Kalendarz'
              style: TextStyle(
                color: Colors.white,
              ),
            );
          },
        ),

        // uczestnicy kalendarza
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.group_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ParticipantsScreen(calendarId: calendarId),
                ),
              );
            },
          ),
        ],
      ),

      // kaledarz
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: DateTime.now(),
            selectedDayPredicate: (day) {
              return isSameDay(DateTime.now(), day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DayDetailsScreen(
                      selectedDay: selectedDay, calendarId: calendarId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
