import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'day.dart';
import 'members_page.dart';
import 'providers/calendar_provider.dart';

class Calendar extends ConsumerWidget {
  final String calendarId;

  const Calendar({Key? key, required this.calendarId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarRepository = ref.watch(calendarRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: calendarRepository.getCalendarName(calendarId),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? 'Kalendarz',
              style: TextStyle(
                color: Colors.white,
              ),
            );
          },
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.group_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MembersPage(calendarId: calendarId),
                ),
              );
            },
          ),
        ],
      ),
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
                  builder: (context) =>
                      Day(selectedDay: selectedDay, calendarId: calendarId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
