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
    final calendarService = ref.watch(calendarServiceProvider);

    return StreamBuilder<QuerySnapshot>(
      stream: calendarService.getEventsForDay(calendarId, selectedDay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Brak wydarzeń na ten dzień'));
        } else {
          // sortowanie dokumentów chronologicznie
          var sortedDocuments = sortEvents(snapshot.data!);

          return ListView.builder(
            itemCount: sortedDocuments.length,
            itemBuilder: (context, index) {
              var doc = sortedDocuments[index];
              var data = doc.data() as Map<String, dynamic>;
              String eventName = data['name'];
              String eventType =
                  data['event_type']; // Dodane pobranie typu wydarzenia
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
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            endTimeFormatted,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 8),
                      Container(
                        height: 50,
                        child: VerticalDivider(
                          width: 4.0,
                          color: Theme.of(context).primaryColor,
                          thickness: 4.0,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventName,
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              eventType, // Wyświetlenie typu wydarzenia
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.grey[700]),
                        onPressed: () {
                          showDeleteDialog(
                            context,
                            calendarService,
                            calendarId,
                            doc.id,
                            selectedDay,
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                ],
              );
            },
          );
        }
      },
    );
  }

  // usuwanie wydarzenia
  void showDeleteDialog(
    BuildContext context,
    CalendarService calendarService,
    String calendarId,
    String eventId,
    DateTime selectedDay,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text("Czy na pewno chcesz usunąć to wydarzenie?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Anuluj"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                calendarService
                    .deleteEvent(calendarId, eventId, selectedDay)
                    .then(
                      (_) => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Wydarzenie zostało usunięte')),
                      ),
                    )
                    .catchError(
                      (error) => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nie udało się usunąć wydarzenia'),
                        ),
                      ),
                    );
              },
              child: Text("Usuń"),
            ),
          ],
        );
      },
    );
  }
}

List<DocumentSnapshot> sortEvents(QuerySnapshot snapshot) {
  return snapshot.docs.toList()
    ..sort((eventA, eventB) {
      Timestamp eventAStart =
          (eventA.data() as Map<String, dynamic>)['start_time'];
      Timestamp eventBStart =
          (eventB.data() as Map<String, dynamic>)['start_time'];
      return eventAStart.compareTo(eventBStart);
    });
}
