import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/notes_theme.dart';
import 'firebase_options.dart';
import 'screens/wrapper_screen.dart';
import 'services/app_remote_config_service.dart';
import 'services/crash_reporting_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CrashReportingService.instance.initialize();
  await AppRemoteConfigService.instance.initialize();
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: AppRemoteConfigService.instance.accentColor,
      builder: (context, accentColor, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'QuickNotes',
          theme: NotesTheme.light(accent: accentColor),
          // WrapperScreen listens to FirebaseAuth.authStateChanges()
          // and routes to LoginScreen or NotesHomeScreen automatically.
          home: const WrapperScreen(),
        );
      },
    );
  }
}
