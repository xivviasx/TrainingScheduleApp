import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/calendar_provider.dart';

class EventList extends ConsumerWidget {
  final DateTime selectedDay;
  final String calendarId;

  const EventList({
    Key? key,
    required this.selectedDay,
    required this.calendarId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarRepository = ref.watch(calendarRepositoryProvider);

    return StreamBuilder<QuerySnapshot>(
      stream: calendarRepository.getEventsForDay(calendarId, selectedDay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Brak wydarzeń na ten dzień'));
        } else {
          List<Widget> eventWidgets = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String eventName = data['name'];
            Timestamp startTimestamp = data['start_time'];
            Timestamp endTimestamp = data['end_time'];
            DateTime startTime = startTimestamp.toDate();
            DateTime endTime = endTimestamp.toDate();

            String startTimeFormatted = DateFormat('HH:mm').format(startTime);
            String endTimeFormatted = DateFormat('HH:mm').format(endTime);

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          startTimeFormatted,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          endTimeFormatted,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      height: 40,
                      child: VerticalDivider(
                        width: 4.0,
                        color: Colors.blue,
                        thickness: 4.0,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        eventName,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
              ],
            );
          }).toList();

          return Expanded(
            child: ListView(
              children: eventWidgets,
            ),
          );
        }
      },
    );
  }
}
