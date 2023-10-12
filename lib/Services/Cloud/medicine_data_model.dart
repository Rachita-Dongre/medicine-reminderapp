//data model for medicine

import 'package:flutter/material.dart';

class MedicineModel {
  final String medicineName;
  String dosageAmount;
  int frequency;

  // Use DateTime for a full date & time representation
  //DateTime dateAndTime;

  // If you only want to capture the time part, you can use TimeOfDay
  List<TimeOfDay> doseTimes; // A list to store times for each dose

  String instructions;
  String additionalInformation;

  MedicineModel({
    required this.medicineName,
    required this.dosageAmount,
    required this.frequency,
    //required this.dateAndTime, // Ensure you pass a DateTime object when instantiating
    required this.doseTimes, // Ensure you pass a List<TimeOfDay> object when instantiating
    required this.instructions,
    required this.additionalInformation,
  });
}
