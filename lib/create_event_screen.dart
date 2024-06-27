import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/calendar_provider.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  final DateTime selectedDay;
  final String calendarId;

  const CreateEventScreen({
    Key? key,
    required this.selectedDay,
    required this.calendarId,
  }) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  // Lista dostępnych typów wydarzeń
  List<String> eventTypes = [
    'Trening skokowy',
    'Trening ujeżdżeniowy',
    'Lonżowanie',
    'Zajeżdżanie konia',
    'Spacer',
    'Puszczanie luzem',
    'Inne',
  ];

  // Wybrany typ wydarzenia
  String selectedEventType = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nowy trening',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nazwa:'),
              SizedBox(height: 5),
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(border: OutlineInputBorder()),
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 10),
              Text('Godzina rozpoczęcia:'),
              SizedBox(height: 5),
              TextFormField(
                controller: _startTimeController,
                onTap: () {
                  _selectStartTime(context);
                },
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 10),
              Text('Godzina zakończenia:'),
              SizedBox(height: 5),
              TextFormField(
                controller: _endTimeController,
                onTap: () {
                  _selectEndTime(context);
                },
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 10),
              Text('Typ wydarzenia:'),
              SizedBox(height: 5),
              Column(
                // buttony z typami wydarzenia
                children: eventTypes
                    .map((type) => RadioListTile(
                          title: Text(type),
                          value: type,
                          groupValue: selectedEventType,
                          onChanged: (String? value) {
                            setState(() {
                              selectedEventType = value ?? '';
                            });
                          },
                        ))
                    .toList(),
              ),
              SizedBox(height: 25),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _addEvent(context);
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: Text(
                    'Dodaj',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartTime(BuildContext context) async {
    // okno z wybieraniem godziny
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTimeController.text = '${picked.hour}:${picked.minute}';
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTimeController.text = '${picked.hour}:${picked.minute}';
      });
    }
  }

  Future<void> _addEvent(BuildContext context) async {
    final calendarService = ref.read(calendarServiceProvider);

    DateTime startDateTime = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
      int.parse(_startTimeController.text.split(':')[0]),
      int.parse(_startTimeController.text.split(':')[1]),
    );
    DateTime endDateTime = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
      int.parse(_endTimeController.text.split(':')[0]), // godzina
      int.parse(_endTimeController.text.split(':')[1]), // minuty
    );

    // Przekazanie danych do dostawcy
    await calendarService.addEvent(
      widget.calendarId,
      widget.selectedDay,
      _eventNameController.text,
      startDateTime,
      endDateTime,
      selectedEventType,
    );

    Navigator.pop(context);
  }
}
