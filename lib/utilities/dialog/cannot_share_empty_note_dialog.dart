import 'package:flutter/material.dart';
import 'package:todo_app/utilities/dialog/generic_dialog.dart';

Future<void> showCannotShowEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'sharing',
    content: 'You can not share an empty note!',
    optionBuilder: () => {
      'OK': null,
    },
  );
}
