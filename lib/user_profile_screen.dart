import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/user_profile_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Container(
      padding: EdgeInsets.all(20.0),
      child: userProfile.when(
        data: (userProfile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Imię:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                userProfile.firstName,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Text(
                'Nazwisko:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                userProfile.lastName,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Text(
                'Email:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                userProfile.email,
                style: TextStyle(fontSize: 20),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
