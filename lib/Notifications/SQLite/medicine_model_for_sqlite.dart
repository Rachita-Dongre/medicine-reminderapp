import 'package:flutter/material.dart';
import 'package:medicinereminder/Notifications/SQLite/Utility/time_of_day_utils.dart';

class Medicine {
  String? id;
  String medicineName;
  String dosageAmount;
  List<TimeOfDay> doseTimes;

  Medicine(
      {this.id,
      required this.medicineName,
      required this.dosageAmount,
      required this.doseTimes});

  // Converter methods to go from and to Map (useful for database operations)

  Map<String, dynamic> toMap() {
    return {
      'medicine_name': medicineName,
      'dosage_amount': dosageAmount,
      'dose_times': doseTimes.map(TimeOfDayUtils.serializeTimeOfDay).toList(),
    };
  }

  // static Medicine fromMap(Map<String, dynamic> map) {
  //   return Medicine(
  //     medicineName: map['medicine_name'],
  //     dosageAmount: map['dosage_amount'],
  //     doseTimes: (map['dose_times'] as List)
  //         .map((e) => TimeOfDayUtils.deserializeTimeOfDay(e))
  //         .toList(),
  //   );
  // }

  // static Medicine fromMap(Map<String, dynamic> map) {
  //   List<String> doseTimeStrings = map['doseTimes'].split(",");
  //   return Medicine(
  //     medicineName: map['medicine_name'],
  //     dosageAmount: map['dosage_amount'],
  //     doseTimes: doseTimeStrings
  //         .map((e) => TimeOfDayUtils.deserializeTimeOfDay(e))
  //         .toList(),
  //   );
  // }

  static Medicine fromMap(Map<String, dynamic> map) {
    List<String> doseTimeStrings =
        (map['dose_times'] as String?)?.split(",") ?? [];
    return Medicine(
      medicineName: map['medicine_name'],
      dosageAmount: map['dosage_amount'],
      doseTimes: doseTimeStrings
          .map((e) => TimeOfDayUtils.deserializeTimeOfDay(e))
          .toList(),
    );
  }
}
