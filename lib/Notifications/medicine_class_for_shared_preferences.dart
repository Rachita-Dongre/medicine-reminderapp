// import 'package:flutter/material.dart';

// class Medicine {
//   final String name;
//   final String dosageAmount;
//   final List<TimeOfDay> doseTimes;

//   Medicine(
//       {required this.name,
//       required this.dosageAmount,
//       required this.doseTimes});

//   // Convert a Medicine object into a Map
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'dosageAmount': dosageAmount,
//       'doseTimes':
//           doseTimes.map((time) => '${time.hour}:${time.minute}').toList(),
//     };
//   }

//   // Convert a Map into a Medicine object
//   factory Medicine.fromMap(Map<String, dynamic> map) {
//     List<TimeOfDay> convertedDoseTimes =
//         (map['doseTimes'] as List).map((timeString) {
//       final splitTime = timeString.split(':');
//       return TimeOfDay(
//           hour: int.parse(splitTime[0]), minute: int.parse(splitTime[1]));
//     }).toList();

//     return Medicine(
//       name: map['name'],
//       dosageAmount: map['dosageAmount'],
//       doseTimes: convertedDoseTimes,
//     );
//   }
// }
