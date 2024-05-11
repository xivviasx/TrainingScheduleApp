import 'package:flutter/material.dart';

class Day extends StatelessWidget {
  final DateTime selectedDay;

  const Day({Key? key, required this.selectedDay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.blue[100],
      child: Row(
        children: [
          Text(
            'Treningi dnia: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${selectedDay.day}.${selectedDay.month}.${selectedDay.year}',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
