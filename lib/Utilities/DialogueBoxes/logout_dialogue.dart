//the dialog box that gets displayed on clicking the "log out" button!
import 'package:flutter/material.dart';

Future<bool> showLogOutDialogue(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you wanna log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text(
              'Cancel',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text(
              'Log Out',
            ),
          ),
        ],
      );
    },
  ).then((value) =>
      value ??
      false); //thw user can dismiss the dialogue box without interacting with it, so we either return the value or return false
}
