import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todo_app/services/auth/auth_service.dart';
import 'package:todo_app/services/cloud/cloud_note.dart';
import 'package:todo_app/services/cloud/firebase_cloud_storage.dart';
import 'package:todo_app/utilities/generic/get_argument.dart';

import '../../utilities/dialog/cannot_share_empty_note_dialog.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNotes? _notes;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textEditingController;
  @override
  void initState() {
    _textEditingController = TextEditingController();
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  Future<CloudNotes> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNotes>();
    if (widgetNote != null) {
      _notes = widgetNote;
      _textEditingController.text = widgetNote.text;
      return widgetNote;
    }
    final existingNotes = _notes;
    if (existingNotes != null) {
      return existingNotes;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNotes = await _notesService.createNewNotes(ownerUserId: userId);
    _notes = newNotes;
    return newNotes;
  }

  void _deleteNoteIfEmpty() {
    final note = _notes;
    if (_textEditingController.text.isEmpty && note != null) {
      _notesService.deleteNotes(
        documentId: note.documentId,
      );
    }
  }

  void _saveNotesIfNotEmpty() async {
    final note = _notes;
    final text = _textEditingController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNotes(
        documentId: note.documentId,
        text: text,
      );
    }
  }

  void _textControllerListener() async {
    final note = _notes;
    if (note == null) {
      return;
    }
    final text = _textEditingController.text;
    await _notesService.updateNotes(
      documentId: note.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textEditingController.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNotesIfNotEmpty();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New notes'),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textEditingController.text;
              if (_notes == null || text.isEmpty) {
                await showCannotShowEmptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(
              Icons.share,
            ),
          )
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: 'Start typing here...',
                    hintStyle: TextStyle(color: Colors.black)),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
