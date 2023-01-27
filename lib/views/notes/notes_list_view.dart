import 'package:flutter/material.dart';

import '../../services/crud/notes_services.dart';

typedef DeleteNotesCallback = void Function(DataBaseNotes note);

class NotesListView extends StatefulWidget {
  final List<DataBaseNotes> notes;
  final DeleteNotesCallback onDeleteNotes;
  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNotes,
  });

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
