import 'package:flutter/material.dart';
import 'package:todo_app/utilities/dialog/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog(
      context: context,
      title: 'An error occurred',
      content: text,
      optionBuilder: () => {'Ok': null});
}
