import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/app/notes_theme.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/screens/login_screen.dart';
import 'package:notes_app/screens/note_details_screen.dart';
import 'package:notes_app/screens/note_editor_screen.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: NotesTheme.light(accent: const Color(0xFF0AD9D9)),
      home: child,
    );
  }

  testWidgets('renders the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(const LoginScreen()));

    expect(find.text('QuickNotes'), findsOneWidget);
    expect(find.text('Capture your thoughts instantly.'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('renders the note editor fields', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp(const NoteEditorScreen()));

    expect(find.text('New Note'), findsOneWidget);
    expect(find.text('Note Title'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
    expect(find.text('Save Note'), findsOneWidget);
  });

  testWidgets('renders note details content', (WidgetTester tester) async {
    final note = Note(
      id: '1',
      title: 'Meeting Notes',
      body: 'This is a note body.',
    );

    await tester.pumpWidget(buildTestApp(NoteDetailsScreen(note: note)));

    expect(find.text('Note Details'), findsOneWidget);
    expect(find.text('Meeting Notes'), findsOneWidget);
    expect(find.text('This is a note body.'), findsOneWidget);
  });
}
