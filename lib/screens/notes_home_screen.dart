import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../app/notes_theme.dart';
import '../helpers/collection_names.dart';
import '../models/note.dart';
import '../services/app_remote_config_service.dart';
import '../services/crash_reporting_service.dart';
import 'note_details_screen.dart';
import 'note_editor_screen.dart';

class NotesHomeScreen extends StatelessWidget {
  const NotesHomeScreen({super.key});

  User? get _user => FirebaseAuth.instance.currentUser;

  CollectionReference<Note> get _notesCollection => FirebaseFirestore.instance
      .collection(CN.users)
      .doc(_user?.uid)
      .collection(CN.notes)
      .withConverter<Note>(
        fromFirestore: Note.fromFirestore,
        toFirestore: (note, _) => note.toFirestore(),
      );

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar
            Container(
              height: 72,
              color: backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  // User Avatar & Name
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: NotesPalette.border,
                          backgroundImage: _user?.photoURL != null
                              ? NetworkImage(_user!.photoURL!)
                              : null,
                          child: _user?.photoURL == null
                              ? const Icon(
                                  Icons.person_outline,
                                  size: 20,
                                  color: NotesPalette.muted,
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello,',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: NotesPalette.muted,
                                    height: 1.1,
                                  ),
                            ),
                            Text(
                              _user?.displayName?.split(' ').first ?? 'Notes',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _refreshTheme(context),
                        icon: const Icon(Icons.palette_outlined, size: 22),
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: 'Refresh remote theme',
                      ),
                      IconButton(
                        onPressed: _triggerCrash,
                        icon: const Icon(Icons.bug_report_outlined, size: 22),
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: 'Test Crashlytics',
                      ),
                      IconButton(
                        onPressed: () => _openEditor(context),
                        icon: const Icon(Icons.add_rounded, size: 28),
                        color: NotesPalette.ink,
                        tooltip: 'Add note',
                      ),
                      IconButton(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout_rounded, size: 22),
                        color: NotesPalette.muted,
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Notes list
            Expanded(
              child: StreamBuilder<QuerySnapshot<Note>>(
                stream: _notesCollection
                    .orderBy('updatedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Something went wrong.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.note_alt_outlined,
                            size: 64,
                            color: NotesPalette.border,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No notes yet.\nTap + to add one.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: NotesPalette.muted),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final note = doc.data();

                      return Dismissible(
                        key: Key(doc.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.red.shade400,
                          padding: const EdgeInsets.only(right: AppSpacing.lg),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) async {
                          try {
                            await _notesCollection.doc(doc.id).delete();
                          } catch (error, stackTrace) {
                            await CrashReportingService.instance.recordError(
                              error,
                              stackTrace,
                              reason: 'delete_note_failed',
                            );
                          }
                        },
                        child: InkWell(
                          onTap: () => _openDetails(context, note),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 82),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            color: backgroundColor,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note.title,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        note.body,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: NotesPalette.muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, {Note? note}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => NoteEditorScreen(note: note)),
    );
  }

  void _openDetails(BuildContext context, Note note) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => NoteDetailsScreen(note: note)),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshTheme(BuildContext context) async {
    try {
      await AppRemoteConfigService.instance.refresh();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Remote Config refreshed.')));
    } catch (error, stackTrace) {
      await CrashReportingService.instance.recordError(
        error,
        stackTrace,
        reason: 'remote_config_refresh_failed',
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh theme: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _triggerCrash() {
    FirebaseCrashlytics.instance.crash();
  }
}
