import 'package:flutter/material.dart';
import 'package:medicinereminder/Constants/routes.dart';
import 'package:medicinereminder/Notifications/SQLite/database_helper.dart';
import 'package:medicinereminder/Notifications/notification_scheduler.dart';
import 'package:medicinereminder/Services/Cloud/cloud_storage_exceptions.dart';
import 'package:medicinereminder/Services/Cloud/crud_cloud_firestore.dart';
import 'package:medicinereminder/Utilities/DialogueBoxes/confirmation_dialogue.dart';
import 'package:medicinereminder/Utilities/DialogueBoxes/error_dialogue.dart';
import 'package:uuid/uuid.dart';

class AddMedicine extends StatefulWidget {
  const AddMedicine({super.key});

  @override
  State<AddMedicine> createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  late final String? userId = Database.userID;
  int frequency = 0;

  List<TimeOfDay?> doseTimes = [];

  NotificationServices notificationServices = NotificationServices();

  var uuid = const Uuid();

  // SharedPreferencesForNotifications sharedPreferencesForNotifications =
  //     SharedPreferencesForNotifications();

  Future<void> selectTime(int index) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  TextEditingController medicineNameController = TextEditingController();
  TextEditingController dosageAmountController = TextEditingController();
  TextEditingController frequencyController = TextEditingController();
  TextEditingController instructionsController = TextEditingController();
  TextEditingController additionalInformationController =
      TextEditingController();

  final FocusNode _focusNodeMedicineName = FocusNode();
  final FocusNode _focusNodedosageAmount = FocusNode();
  final FocusNode _focusNodeFrequency = FocusNode();
  final FocusNode _focusNodeInstructions = FocusNode();
  final FocusNode _focusNodeAdditionalInformation = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNodeMedicineName.addListener(() {
      if (!_focusNodeMedicineName.hasFocus) {
        _formKey.currentState!.validate();
      }
    });
    _focusNodedosageAmount.addListener(() {
      if (!_focusNodedosageAmount.hasFocus) {
        _formKey.currentState!.validate();
      }
    });
    _focusNodeFrequency.addListener(() {
      if (!_focusNodeFrequency.hasFocus) {
        _formKey.currentState!.validate();
      }
    });
    _focusNodeInstructions.addListener(() {
      if (!_focusNodeInstructions.hasFocus) {
        _formKey.currentState!.validate();
      }
    });
    _focusNodeAdditionalInformation.addListener(() {
      if (!_focusNodeAdditionalInformation.hasFocus) {
        _formKey.currentState!.validate();
      }
    });
  }

  @override
  void dispose() {
    medicineNameController.dispose();
    dosageAmountController.dispose();
    frequencyController.dispose();
    instructionsController.dispose();
    additionalInformationController.dispose();

    _focusNodeMedicineName.dispose();
    _focusNodedosageAmount.dispose();
    _focusNodeFrequency.dispose();
    _focusNodeInstructions.dispose();
    _focusNodeAdditionalInformation.dispose();
    super.dispose();
  }

  Future<void> onAddPressed() async {
    String medicineId = uuid.v4();

    print("Calling sqlite DBhelper");
    await callSqliteDBhelper(medicineId);

    print("calling notification service");
    await callNotificationService(medicineId);

    print("calling addmedicine");
    await callAddMedicine(medicineId);
    //callStoreMedicineInSharedPreferences();

    Navigator.pushNamedAndRemoveUntil(
        context, medicineHomeRoute, (route) => false);
  }

  List<TimeOfDay> nullToNonNullTime(List<TimeOfDay?> timeList) {
    return timeList.where((time) => time != null).cast<TimeOfDay>().toList();
  }

  late List<TimeOfDay> timeListForSqlite;

  Future<void> callSqliteDBhelper(String id) async {
    print("inside callSqliteDBhelper");
    timeListForSqlite = nullToNonNullTime(doseTimes);
    await DatabaseHelper.instance.insertMedicine(
      id: id,
      medicineName: medicineNameController.text,
      dosageAmount: dosageAmountController.text,
      doseTimes: timeListForSqlite,
    );
    print("reached end of SqliteDBhelper");
  }

  Future<void> callNotificationService(String medicineId) async {
    print("inside callNotificationService");
    try {
      notificationServices.notificationsHelper(
          medicineId, medicineNameController.text);
    } catch (e) {
      print("Error in callNotificationService: $e");
      showErrorDialog(
        context,
        'Could not schedule notification. Try Again!',
      );
    }
    print("reached end of callNotificationService");
  }

  Future<void> callAddMedicine(String uuid) async {
    print("inside callAddmedicine");
    try {
      await Database.addMedicine(
        medicineName: medicineNameController.text,
        dosageAmount: dosageAmountController.text,
        frequency: frequency,
        doseTime: doseTimes,
        instructions: instructionsController.text,
        additionalInformation: additionalInformationController.text,
        userID: userId,
        uuid: uuid,
      );
      showConfirmationDialog(context, 'Medicine succesfully added!');
    } on CouldNotCreateMedicineException {
      showErrorDialog(
        context,
        'Could not add medicine. Try Again!',
      );
    } catch (e) {
      showErrorDialog(
        context,
        'Could not add medicine. Try Again!',
      );
    }
    print("reached end of callAddMedicine");
  }

  // List<TimeOfDay> nullToNonNullTime(List<TimeOfDay?> timeList) {
  //   return timeList.where((time) => time != null).cast<TimeOfDay>().toList();
  // }

  // late List<TimeOfDay> timeListForSharedPreferences;

  // void callStoreMedicineInSharedPreferences() {
  //   try {
  //     timeListForSharedPreferences = nullToNonNullTime(doseTimes);
  //     sharedPreferencesForNotifications.storeMedicineData(
  //       medicineNameController.text,
  //       dosageAmountController.text,
  //       timeListForSharedPreferences,
  //     );
  //   } catch (e) {
  //     print("error while storing data in shared preferences : $e");
  //   }
  // }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[300],
      appBar: AppBar(
        title: const Text('Add some medicines!'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
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
                      focusNode: _focusNodeMedicineName,
                      decoration: InputDecoration(
                        errorStyle: const TextStyle(
                            color: Colors.redAccent, fontSize: 12),
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
                const SizedBox(
                  height: 20,
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
                      focusNode: _focusNodedosageAmount,
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
                const SizedBox(
                  height: 20,
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
                      focusNode: _focusNodeFrequency,
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
                            frequency = tempFrequency;
                            doseTimes =
                                List<TimeOfDay?>.filled(frequency, null);
                          });
                        }
                      },
                    ),
                  ),
                ),
                //generating a list of time pickers
                //if (frequency != null)
                ...List.generate(frequency, (index) {
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
                      onTap: () async {
                        await selectTime(index);
                      },
                    ),
                  );
                }),

                const SizedBox(
                  height: 12,
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
                      controller: instructionsController,
                      focusNode: _focusNodeInstructions,
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
                const SizedBox(
                  height: 12,
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
                      focusNode: _focusNodeAdditionalInformation,
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        onAddPressed();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please fill out all required fields.'),
                          ),
                        );
                      }
                    },
                    child: const Text('Add'),
                  ),
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
