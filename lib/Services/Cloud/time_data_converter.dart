import 'package:flutter/material.dart'; //This class handles conversion of time
//since the time format compatible with firestore is in map format, and in flutter its a different datatype called TimeOfDay

class MedicineDataConverter {
  // Convert TimeOfDay to Map for Firestore
  static Map<String, int> timeOfDayToMap(TimeOfDay? time) {
    return {
      'hour': time?.hour ?? 0,
      'minute': time?.minute ?? 0,
    };
  }

  // Convert Map from Firestore to TimeOfDay
  static TimeOfDay mapToTimeOfDay(Map<String, dynamic> timeData) {
    return TimeOfDay(hour: timeData['hour'], minute: timeData['minute']);
  }

  // Convert List<TimeOfDay> to List<Map> for Firestore
  static List<Map<String, int>> timeOfDayListToMapList(List<TimeOfDay?> times) {
    return times.map(timeOfDayToMap).toList();
  }

  // Convert List<Map> from Firestore to List<TimeOfDay>
  static List<TimeOfDay> mapListToTimeOfDayList(List<dynamic> timesData) {
    return timesData
        .map((data) => mapToTimeOfDay(data as Map<String, dynamic>))
        .toList();
  }
}
