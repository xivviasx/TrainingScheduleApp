import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateEventScreen extends StatefulWidget {
  final DateTime selectedDay;
  final String calendarId;

  const CreateEventScreen({
    Key? key,
    required this.selectedDay,
    required this.calendarId,
  }) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void dispose() {
    _eventNameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

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
    );
  }

  Future<void> _selectStartTime(BuildContext context) async {
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
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
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
        int.parse(_endTimeController.text.split(':')[0]),
        int.parse(_endTimeController.text.split(':')[1]),
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
