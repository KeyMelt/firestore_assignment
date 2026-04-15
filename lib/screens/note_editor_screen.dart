import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app/notes_theme.dart';
import '../helpers/collection_names.dart';
import '../models/note.dart';

/// Screen for creating a new note or editing an existing one.
///
/// Pass [docId] and [existing] data when editing; leave both null to create.
class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key, this.note});

  /// The note being edited. `null` = new note.
  final Note? note;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _isSaving = false;

  bool get _isEditing => widget.note != null;

  User? get _user => FirebaseAuth.instance.currentUser;

  CollectionReference<Note> get _notesCollection =>
      FirebaseFirestore.instance
          .collection(CN.users)
          .doc(_user?.uid)
          .collection(CN.notes)
          .withConverter<Note>(
            fromFirestore: Note.fromFirestore,
            toFirestore: (note, _) => note.toFirestore(),
          );

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.note?.title ?? '',
    );
    _bodyController = TextEditingController(
      text: widget.note?.body ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        // Update existing document
        final updatedNote = widget.note!.copyWith(
          title: title,
          body: body,
          updatedAt: DateTime.now(), // Trigger server timestamp in toFirestore if needed, or use now
        );
        await _notesCollection.doc(widget.note!.id).set(updatedNote);
      } else {
        // Create new document
        final newNote = Note(
          id: '', // Firestore generates the ID
          title: title,
          body: body,
        );
        await _notesCollection.add(newNote);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ────────────────────────────────────────────────────
            Container(
              height: 72,
              color: NotesPalette.canvas,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: NotesPalette.ink,
                  ),
                  Expanded(
                    child: Text(
                      _isEditing ? 'Edit Note' : 'New Note',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer to balance the back button
                ],
              ),
            ),

            // ── Fields ─────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  _LabeledField(
                    label: 'Note Title',
                    child: TextField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      enabled: !_isSaving,
                      decoration: const InputDecoration(
                        hintText: 'Enter note title',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _LabeledField(
                    label: 'Content',
                    child: TextField(
                      controller: _bodyController,
                      minLines: 6,
                      maxLines: 12,
                      textAlignVertical: TextAlignVertical.top,
                      enabled: !_isSaving,
                      decoration: const InputDecoration(
                        hintText: 'Enter note content',
                        constraints: BoxConstraints(minHeight: 144),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Save button ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton(
                      onPressed: _save,
                      child: const Text('Save Note'),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}
