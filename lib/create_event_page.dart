import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateEventPage extends StatefulWidget {
  final DateTime selectedDay;
  final String calendarId;

  const CreateEventPage(
      {Key? key, required this.selectedDay, required this.calendarId})
      : super(key: key);

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _eventNameController = TextEditingController();

  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime =
      TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nowy trening')),
      body: Padding(
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
            InkWell(
              onTap: () {
                _selectStartTime(context);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${_startTime.hour}:${_startTime.minute}',
                      style: TextStyle(color: Colors.black),
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Text('Godzina zakończenia:'),
            SizedBox(height: 5),
            InkWell(
              onTap: () {
                _selectEndTime(context);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${_endTime.hour}:${_endTime.minute}',
                      style: TextStyle(color: Colors.black),
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _addEvent(context);
              },
              child: Text('Dodaj'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _addEvent(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DateTime startDateTime = DateTime(
        widget.selectedDay.year,
        widget.selectedDay.month,
        widget.selectedDay.day,
        _startTime.hour,
        _startTime.minute,
      );
      DateTime endDateTime = DateTime(
        widget.selectedDay.year,
        widget.selectedDay.month,
        widget.selectedDay.day,
        _endTime.hour,
        _endTime.minute,
      );

      String formattedDate =
          '${widget.selectedDay.year}-${widget.selectedDay.month}-${widget.selectedDay.day}';

      CollectionReference eventsCollection = FirebaseFirestore.instance
          .collection('calendars')
          .doc(widget.calendarId)
          .collection('events')
          .doc(formattedDate)
          .collection('dayEvents');

      await eventsCollection.add({
        'name': _eventNameController.text,
        'start_time': Timestamp.fromDate(startDateTime),
        'end_time': Timestamp.fromDate(endDateTime),
        'created_by': user.uid,
      });

      Navigator.pop(context);
    }
  }
}
