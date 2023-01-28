import 'package:flutter/material.dart';
import 'package:todo_app/utilities/dialog/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Log out',
    content: 'Are you sure you want to logout',
    optionBuilder: () => {'Cancel': false, 'Log Out': true},
  ).then(
    (value) => value ?? false,
  );
}
