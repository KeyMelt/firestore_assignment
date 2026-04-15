import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'notes_home_screen.dart';
import 'login_screen.dart';

/// Listens to [FirebaseAuth.authStateChanges] and routes to the correct
/// screen automatically – no cubit or state management needed.
class WrapperScreen extends StatelessWidget {
  const WrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          return const NotesHomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
