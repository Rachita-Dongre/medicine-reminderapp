// import 'package:flutter/material.dart';
// import 'package:medicinereminder/Notifications/medicine_class_for_shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SharedPreferencesForNotifications {
//   String serializeTimeOfDay(TimeOfDay time) {
//     return '${time.hour}:${time.minute}';
//   }

//   TimeOfDay deserializeTimeOfDay(String time) {
//     final parts = time.split(':');
//     return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
//   }

//   Future<bool> storeMedicineData(
//       String name, String dosageAmount, List<TimeOfDay> doseTimes) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Convert List<TimeOfDay> to List<String>
//     List<String> serializedTimes = doseTimes.map(serializeTimeOfDay).toList();

//     await prefs.setString('medicine_name', name);
//     await prefs.setString('dosage_amount', dosageAmount);
//     await prefs.setStringList('dose_times', serializedTimes);

//     return true;
//   }

//   Future<Medicine?> getMedicineData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     String? name = prefs.getString('medicine_name');
//     String? dosageAmount = prefs.getString('dosage_amount');
//     List<String>? serializedTimes = prefs.getStringList('dose_times');

//     if (name != null && dosageAmount != null && serializedTimes != null) {
//       List<TimeOfDay> doseTimes =
//           serializedTimes.map(deserializeTimeOfDay).toList();
//       return Medicine(
//           name: name, dosageAmount: dosageAmount, doseTimes: doseTimes);
//     }
//     return null;
//   }
// }
