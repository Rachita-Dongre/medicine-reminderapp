//confirmation dialogue box that's shown on clicking delete button
import 'package:flutter/material.dart';
import 'package:medicinereminder/Notifications/SQLite/database_helper.dart';
import 'package:medicinereminder/Notifications/notification_scheduler.dart';
import 'package:medicinereminder/Services/Cloud/crud_cloud_firestore.dart';
import 'package:medicinereminder/Services/cloud/cloud_storage_exceptions.dart';
import 'package:medicinereminder/Utilities/DialogueBoxes/error_dialogue.dart';

Future<bool> deleteConfirmationDialogue(BuildContext context, docID, sqliteId) {
  NotificationServices notificationServices = NotificationServices();
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Medicine'),
        content: const Text('Are you sure you wanna delete the medicine?'),
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
            onPressed: () async {
              try {
                notificationServices.cancelNotification(sqliteId);
                await DatabaseHelper.instance.deleteMedicine(sqliteId);
                await Database.deleteMedicine(docID: docID);
              } on CouldNotDeleteMedicineException {
                showErrorDialog(
                  context,
                  'Could not delete medicine. Try Again!',
                );
              } catch (e) {
                showErrorDialog(
                  context,
                  'Could not delete medicine. Try Again!',
                );
              } finally {
                Navigator.of(context).pop(); // Close the dialog
              }
            },
            child: const Text(
              'Delete',
            ),
          ),
        ],
      );
    },
  ).then((value) =>
      value ??
      false); //the user can dismiss the dialogue box without interacting with it, so we either return the value or return false
}
