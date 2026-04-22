import 'package:flutter/material.dart';

import '../app/notes_theme.dart';
import '../models/note.dart';
import 'note_editor_screen.dart';

/// Read-only view of a single note. The edit button navigates to [NoteEditorScreen].
class NoteDetailsScreen extends StatelessWidget {
  const NoteDetailsScreen({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final title = note.title;
    final body = note.body;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ────────────────────────────────────────────────────
            Container(
              height: 72,
              color: backgroundColor,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: NotesPalette.ink,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Note Details',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed: () => _openEditor(context),
                      icon: const Icon(Icons.edit_outlined),
                      color: NotesPalette.ink,
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      20,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xxs,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: Text(
                      body,
                      style: Theme.of(context).textTheme.bodyLarge,
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

  void _openEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => NoteEditorScreen(note: note)),
    );
  }
}
