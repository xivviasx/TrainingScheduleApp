import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartScreen extends StatelessWidget {
  final DateTime selectedDay;
  final String calendarId;

  const ChartScreen(
      {Key? key, required this.selectedDay, required this.calendarId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wykres wydarzeń',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<DateTime>>(
          stream: getEventsForDayAsDateTimeList(calendarId, selectedDay),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Brak wydarzeń'));
            } else {
              return _buildChart(snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  Stream<List<DateTime>> getEventsForDayAsDateTimeList(
      String calendarId, DateTime selectedDay) {
    String dateString =
        '${selectedDay.year}-${selectedDay.month}-${selectedDay.day}';

    return FirebaseFirestore.instance
        .collection('calendars')
        .doc(calendarId)
        .collection('events')
        .doc(dateString)
        .collection('dayEvents')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Timestamp timestamp =
            doc.get('start_time'); // Assuming 'start_time' is a Timestamp
        return timestamp.toDate();
      }).toList();
    });
  }

  Widget _buildChart(List<DateTime> events) {
    // Creating data for the chart
    Map<int, int> hourlyCounts = {};
    for (DateTime event in events) {
      int hour = event.hour;
      hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
    }

    List<charts.Series<int, String>> series = [
      charts.Series<int, String>(
        id: 'Events',
        domainFn: (int count, index) => index.toString(),
        measureFn: (int count, _) => count,
        data: List.generate(24, (index) => hourlyCounts[index] ?? 0),
        labelAccessorFn: (int count, _) => count.toString(),
      )
    ];

    return charts.BarChart(
      series,
      animate: true,
      vertical: false,
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(labelRotation: 60),
      ),
    );
  }
}
