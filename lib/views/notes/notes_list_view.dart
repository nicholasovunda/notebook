import 'package:flutter/material.dart';

import '../../services/crud/notes_services.dart';
import '../../utilities/dialog/delete_dialog.dart';

typedef NotesCallback = void Function(DataBaseNotes note);

class NotesListView extends StatelessWidget {
  final List<DataBaseNotes> notes;
  final NotesCallback onDeleteNotes;
  final NotesCallback onTap;
  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNotes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          onTap: () {
            onTap(note);
          },
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black),
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNotes(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
