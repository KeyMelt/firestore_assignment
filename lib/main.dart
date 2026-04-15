import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/notes_theme.dart';
import 'firebase_options.dart';
import 'screens/wrapper_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuickNotes',
      theme: NotesTheme.light,
      // WrapperScreen listens to FirebaseAuth.authStateChanges()
      // and routes to LoginScreen or NotesHomeScreen automatically.
      home: const WrapperScreen(),
    );
  }
}
