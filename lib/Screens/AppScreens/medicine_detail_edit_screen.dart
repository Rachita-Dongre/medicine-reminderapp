//This screen will be shown when the user clicks on a particular medicine to see it's details.
//This will also be the edit screen.
//Edit/detail screen

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medicinereminder/Constants/routes.dart';
import 'package:medicinereminder/Notifications/SQLite/database_helper.dart';
import 'package:medicinereminder/Notifications/notification_scheduler.dart';
import 'package:medicinereminder/Services/Cloud/cloud_storage_exceptions.dart';
import 'package:medicinereminder/Services/Cloud/crud_cloud_firestore.dart';
import 'package:medicinereminder/Services/Cloud/time_data_converter.dart';
import 'package:medicinereminder/Utilities/DialogueBoxes/confirmation_dialogue.dart';
import 'package:medicinereminder/Utilities/DialogueBoxes/delete_confirmation_dialogue.dart';
import 'package:medicinereminder/Utilities/DialogueBoxes/error_dialogue.dart';

class MedicineDetailEditScreen extends StatefulWidget {
  final DocumentSnapshot medicineDocument;

  const MedicineDetailEditScreen({super.key, required this.medicineDocument});

  @override
  State<MedicineDetailEditScreen> createState() =>
      _MedicineDetailEditScreenState();
}

class _MedicineDetailEditScreenState extends State<MedicineDetailEditScreen> {
  //String userID = Database.userID!;
  late TextEditingController medicineNameController;
  late TextEditingController dosageAmountController;
  late int selectedFrequency;
  late TextEditingController frequencyController;
  List<TimeOfDay?> doseTimes = [];
  late TextEditingController instructionsController;
  late TextEditingController additionalInformationController;
  //late String currentMedicineName;
  late String uuid;

  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();

    medicineNameController =
        TextEditingController(text: widget.medicineDocument['Medicine Name']);
    dosageAmountController =
        TextEditingController(text: widget.medicineDocument['Dosage Amount']);
    instructionsController =
        TextEditingController(text: widget.medicineDocument['Instructions']);
    additionalInformationController = TextEditingController(
        text: widget.medicineDocument['Additional Information']);

    selectedFrequency = widget.medicineDocument['Frequency'];
    frequencyController =
        TextEditingController(text: selectedFrequency.toString());

    doseTimes = MedicineDataConverter.mapListToTimeOfDayList(
        widget.medicineDocument['Date and Time']);
    //currentMedicineName = widget.medicineDocument["medicine_name"];
    uuid = widget.medicineDocument["uuid"];
  }

  @override
  void dispose() {
    medicineNameController.dispose();
    dosageAmountController.dispose();
    frequencyController.dispose();
    instructionsController.dispose();
    additionalInformationController.dispose();
    super.dispose();
  }

  Future<void> selectTime(int index) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: doseTimes[index] ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      // Check if this time already exists in the list, but exclude the current index
      // because the user might be re-selecting the same time for the current dose.
      if (doseTimes.where((time) => time == pickedTime).isNotEmpty) {
        showErrorDialog(
          context,
          'You have already selected this time for another dose. Please choose a different time.',
        );
      } else {
        setState(() {
          doseTimes[index] = pickedTime;
        });
      }
    }
  }

  List<TimeOfDay> nullToNonNullTime(List<TimeOfDay?> timeList) {
    return timeList.where((time) => time != null).cast<TimeOfDay>().toList();
  }

  late List<TimeOfDay> timeListForUpdateNotification;

  void onUpdatePressed() {
    callNotificationService();
    callUpdateMedicineInSqlite();
    callUpdateMedicine();
    goToHomeScreen();
    showConfirmationDialog(context, "Medicine successfully updated!");
  }

  void callNotificationService() {
    timeListForUpdateNotification = nullToNonNullTime(doseTimes);
    try {
      //updating notifications
      notificationServices.updateNotification(
        uuid,
        medicineNameController.text,
        dosageAmountController.text,
        timeListForUpdateNotification,
      );
    } catch (e) {
      showErrorDialog(
        context,
        'Could not update notification. Try Again!',
      );
    }
  }

  void callUpdateMedicineInSqlite() async {
    timeListForUpdateNotification = nullToNonNullTime(doseTimes);
    await DatabaseHelper.instance.updateMedicine(
      id: uuid,
      medicineName: medicineNameController.text,
      dosageAmount: dosageAmountController.text,
      doseTimes: timeListForUpdateNotification,
    );
  }

  void callUpdateMedicine() async {
    try {
      await Database.updateMedicine(
        medicineName: medicineNameController.text,
        dosageAmount: dosageAmountController.text,
        frequency: selectedFrequency,
        doseTime: doseTimes,
        instructions: instructionsController.text,
        additionalInformation: additionalInformationController.text,
        docID: widget.medicineDocument.id, // using the current document's ID
        uuid: uuid,
      );
    } on CouldNotUpdateMedicineException {
      showErrorDialog(
        context,
        'Could not update medicine. Try Again!',
      );
    } catch (e) {
      showErrorDialog(
        context,
        'Could not update medicine. Try Again!',
      );
    }
  }

  void onDeletePressed() async {
    await deleteConfirmationDialogue(context, widget.medicineDocument.id, uuid);
    goToHomeScreen();
    showConfirmationDialog(context, "Medicine successfully deleted!");
  }

  void goToHomeScreen() {
    Navigator.pushNamedAndRemoveUntil(
        context, medicineHomeRoute, (route) => false);
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[300],
      appBar: AppBar(title: const Text("Medicine Details")),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.deepPurple[50],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: medicineNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.deepPurple[50],
                        labelText: 'Medicine Name',
                        hintText:
                            'Enter medicine name as written on medicine pack',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 10.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the medicine name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.deepPurple[50],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: dosageAmountController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.deepPurple[50],
                        labelText: 'Dose Amount',
                        hintText: 'Ex: 1 tablet, 1 spoon etc.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 10.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Dosage amount';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.deepPurple[50],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: frequencyController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.deepPurple[50],
                        labelText: 'Frequency',
                        hintText: 'No. of doses in a day',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 10.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Frequency value';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        int tempFrequency = int.tryParse(value) ?? 1;
                        if (tempFrequency < 1 || tempFrequency > 10) {
                          showErrorDialog(
                              context, "Input a value between 1 and 10");
                        } else {
                          setState(() {
                            selectedFrequency = tempFrequency;
                            doseTimes = List<TimeOfDay?>.filled(
                                selectedFrequency, null);
                          });
                        }
                      },
                    ),
                  ),
                ),
                ...List.generate(selectedFrequency, (index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.deepPurple[50],
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(doseTimes[index]?.format(context) ??
                          'Select time for dose ${index + 1}'),
                      trailing: const Icon(Icons.timer),
                      onTap: () => selectTime(index),
                    ),
                  );
                }),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.deepPurple[50],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: instructionsController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.deepPurple[50],
                        labelText: 'Instructions',
                        hintText: 'after meals, before meals etc.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 10.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Instructions';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.deepPurple[50],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: additionalInformationController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.deepPurple[50],
                        labelText: 'Additional Information',
                        hintText: 'Any additional information?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 10.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Additional Information';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: onUpdatePressed,
                      child: const Text("Update"),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: onDeletePressed,
                      child: const Text("Delete"),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
