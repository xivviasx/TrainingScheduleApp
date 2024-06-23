import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'providers/calendar_provider.dart';

class ParticipantsScreen extends ConsumerWidget {
  final String calendarId;

  const ParticipantsScreen({Key? key, required this.calendarId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarService = ref.watch(calendarServiceProvider);
    final TextEditingController emailController = TextEditingController();

    void _addMember() {
      String email = emailController.text.trim();
      if (email.isNotEmpty) {
        _addMemberToCalendar(context, ref, emailController, calendarId);
      }
      emailController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Uczestnicy',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _addMember,
                  child: Text(
                    'Dodaj użytkownika',
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  style: ElevatedButton.styleFrom(primary: Colors.grey[300]),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Uczestnicy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, String>>>(
                stream: calendarService.getCalendarMembersInfo(calendarId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Brak uczestników'));
                  } else {
                    return ListView(
                      children: _showMembers(
                          context, snapshot.data!, calendarService, calendarId),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _showMembers(
    BuildContext context,
    List<Map<String, String>> members,
    CalendarService calendarService,
    String calendarId) {
  return members.map((member) {
    String firstName = member['firstName'] ?? '';
    String lastName = member['lastName'] ?? '';
    String email = member['email'] ?? '';

    return ListTile(
      title: Text('$firstName $lastName'),
      subtitle: Text(email),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          _deleteUser(context, calendarService, email, calendarId);
        },
      ),
    );
  }).toList();
}

void _addMemberToCalendar(BuildContext context, WidgetRef ref,
    TextEditingController emailController, String calendarId) async {
  final calendarRepository = ref.read(calendarServiceProvider);
  try {
    await calendarRepository.addParticipantByEmail(
        calendarId, emailController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Użytkownik został pomyślnie dodany')));
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Błąd: ${e.toString()}')));
  }
}

void _deleteUser(BuildContext context, CalendarService calendarService,
    String email, String calendarId) async {
  try {
    await calendarService.removeParticipantByEmail(calendarId, email);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Użytkownik został usunięty')));
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Błąd: ${e.toString()}')));
  }
}
