import 'package:flutter/material.dart';

class TimeOfDayUtils {
  static String serializeTimeOfDay(TimeOfDay time) {
    return '${time.hour}:${time.minute}';
  }

  static TimeOfDay deserializeTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
