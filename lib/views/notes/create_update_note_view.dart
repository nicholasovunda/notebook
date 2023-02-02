import 'package:flutter/material.dart';
import 'package:todo_app/services/auth/auth_service.dart';
import 'package:todo_app/utilities/generic/get_argument.dart';

import '../../services/crud/notes_services.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DataBaseNotes? _notes;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;
  @override
  void initState() {
    _textEditingController = TextEditingController();
    _notesService = NotesService();
    super.initState();
  }

  Future<DataBaseNotes> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DataBaseNotes>();
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
    final email = currentUser.email;
    final owner = await _notesService.getUser(email: email);
    final newNotes = await _notesService.createNotes(owner: owner);
    _notes = newNotes;
    return newNotes;
  }

  void _deleteNoteIfEmpty() {
    final note = _notes;
    if (_textEditingController.text.isEmpty && note != null) {
      _notesService.deleteNotes(id: note.id);
    }
  }

  void _saveNotesIfNotEmpty() async {
    final note = _notes;
    final text = _textEditingController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        note: note,
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
    await _notesService.updateNote(
      note: note,
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
