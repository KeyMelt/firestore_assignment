import 'package:flutter_test/flutter_test.dart';

import 'package:notes_app/main.dart';

void main() {
  testWidgets('renders the login page', (WidgetTester tester) async {
    await tester.pumpWidget(const NotesApp());

    expect(find.text('QuickNotes'), findsOneWidget);
    expect(find.text('Capture your thoughts instantly.'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('login continues to the create note screen', (tester) async {
    await tester.pumpWidget(const NotesApp());

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Create Note'), findsOneWidget);
    expect(find.text('Save Note'), findsOneWidget);
    expect(find.text('View Notes'), findsOneWidget);
  });

  testWidgets('view notes opens the list from create note', (tester) async {
    await tester.pumpWidget(const NotesApp());

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Notes'));
    await tester.pumpAndSettle();

    expect(find.text('Notes List'), findsOneWidget);
    expect(find.text('Meeting Notes'), findsOneWidget);
  });
}
