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
      'name': medicineName,
      'dosageAmount': dosageAmount,
      'doseTimes': doseTimes.map(TimeOfDayUtils.serializeTimeOfDay).toList(),
    };
  }

  static Medicine fromMap(Map<String, dynamic> map) {
    return Medicine(
      medicineName: map['name'],
      dosageAmount: map['dosageAmount'],
      doseTimes: (map['doseTimes'] as List)
          .map((e) => TimeOfDayUtils.deserializeTimeOfDay(e))
          .toList(),
    );
  }
}
