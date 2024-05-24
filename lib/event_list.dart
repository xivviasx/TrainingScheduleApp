import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventList extends StatelessWidget {
  final DateTime selectedDay;
  final String calendarId;

  const EventList({
    Key? key,
    required this.selectedDay,
    required this.calendarId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('XD');
  }
}
