import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'providers/calendar_provider.dart';

class MembersPage extends ConsumerWidget {
  final String calendarId;

  const MembersPage({Key? key, required this.calendarId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarRepository = ref.watch(calendarRepositoryProvider);
    final TextEditingController emailController = TextEditingController();

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
                labelText: 'email',
              ),
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _addMember(context, ref, emailController, calendarId);
                  },
                  child: Text(
                    'Dodaj użytkownika',
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  style: ElevatedButton.styleFrom(primary: Colors.grey[300]),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Members',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: StreamBuilder<List<String>>(
                      stream: calendarRepository
                          .getCalendarMembersNames(calendarId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No members found'));
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(snapshot.data![index]),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _addMember(BuildContext context, WidgetRef ref,
    TextEditingController emailController, String calendarId) async {
  final calendarRepository = ref.read(calendarRepositoryProvider);
  try {
    await calendarRepository.addParticipantByEmail(
        calendarId, emailController.text.trim());
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Member added successfully')));
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
  }
}
