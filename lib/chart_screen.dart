import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'providers/calendar_provider.dart';

class ChartScreen extends ConsumerWidget {
  final DateTime selectedDay;
  final String calendarId;

  const ChartScreen({
    Key? key,
    required this.selectedDay,
    required this.calendarId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarService = ref.watch(calendarServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Oblężenie',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<DateTime>>(
          stream: calendarService.getEventsForDayAsDateTimeList(
              calendarId, selectedDay),
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

  Widget _buildChart(List<DateTime> events) {
    // dane do utworzenia wykresu
    Map<int, int> licznik = {};
    for (DateTime event in events) {
      int hour = event.hour;
      // jesli nie ma jeszcze utworzonego licznika dla danej godziny to tworzy go i ustawia na 0
      licznik[hour] = (licznik[hour] ?? 0) + 1;
    }

    List<charts.Series<int, String>> series = [
      charts.Series<int, String>(
        id: 'Events',
        //oś X, godziny
        domainFn: (int count, index) => index.toString(),
        //oś Y, liczba wydarzeń
        measureFn: (int count, _) => count,
        
        data: List.generate(24, (index) => licznik[index] ?? 0),
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(Colors.black), // kolor wykresu
      )
    ];

    return charts.BarChart(
      series,
      animate: true,
      vertical: false,
      barRendererDecorator: charts.BarLabelDecorator<String>(), // cyfra reprezentująca ilość treningów
    );
  }
}
