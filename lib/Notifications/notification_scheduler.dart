import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medicinereminder/Notifications/SQLite/database_helper.dart';
import 'package:medicinereminder/Notifications/SQLite/medicine_model_for_sqlite.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationServices {
  /*-------------- initializations -------------- */
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings =
      const AndroidInitializationSettings('launcher_icon');

  void initializeNotifications() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /*-------------- initializations - end - here -------------- */

  /*-------------- Utility functions for time data type convertion -------------- */
  // UTILITY FUNCTION to convert the time formats, since time is in map format inside firestore and flutter_local_notificatons package's method works with DateTime format
  // DateTime convertMapToDateTime(Map<String, dynamic> timeMap) {
  //   //This function converts the time from map to the time in CURRENT DATE!
  //   DateTime now = DateTime.now(); // Get the current date.
  //   return DateTime(
  //     // Construct a new DateTime using the current date and the hour and minute from the map.
  //     now.year,
  //     now.month,
  //     now.day,
  //     timeMap['hour']!,
  //     timeMap['minute']!,
  //   );
  // }

  //UTILITY FUNCTION to convert the time from DateTime format to TZDateTime format.
  tz.TZDateTime convertToTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  //UTILITY FUNCTION to convert time from TimeOfDay to DateTime format for update function
  List<DateTime> convertToDateTimeList(List<TimeOfDay> timeOfDayList) {
    DateTime currentDate = DateTime.now();
    return timeOfDayList.map((timeOfDay) {
      return DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
    }).toList();
  }

  /*-------------- Utility functions end -------------- */

  Future<void> notificationsHelper(
      String sqliteMedicineId, String medicineName) async {
    // CollectionReference userMedicines = FirebaseFirestore.instance
    //     .collection('Medicines')
    //     .doc(userId)
    //     .collection('User-Medicines');

    // QuerySnapshot medicinesSnapshot = await userMedicines
    //     .get(); //getting all medicines for a particular user.

    // for (QueryDocumentSnapshot medicineDocument in medicinesSnapshot.docs) {
    //   var medicineData = medicineDocument.data() as Map<String, dynamic>;
    //   List<Map<String, dynamic>?> doseTimesList = List<
    //       Map<String,
    //           dynamic>?>.from(medicineData[
    //       'Date and Time']); //collecting all doseTimes from the user's medicine data and storing in a list
    //   List<DateTime> validDoseTimes =
    //       []; //making a list for doseTimes in DateTime format to pass in scheduleNotification function

    //   for (Map<String, dynamic>? doseTimeMap in doseTimesList) {
    //     if (doseTimeMap != null) {
    //       //converting doseTime from map to DateTime and storing in vaidDoseTimes list
    //       DateTime doseDateTime = convertMapToDateTime(doseTimeMap);
    //       validDoseTimes.add(doseDateTime);
    //     }
    //   }
    //   print('Extracted Valid dose times now printing them');
    //   for (var dosetime in validDoseTimes) {
    //     print(dosetime);
    //   }
    //   print('Number of Doses: ${validDoseTimes.length}');

    //   // Extracting medicine details
    //   String medicineName = medicineData['Medicine Name'];
    //   print(
    //       'Medicine name from which notification is scheduled : $medicineName');
    //   String dosageAmount = medicineData['Dosage Amount'];
    //   print('dosage amount of the medicine : $dosageAmount');

    //   print('now calling scheduleNotification function');

    //   // Scheduling the notification
    //   // Using the user's uid to be used to make notification's unique identifier
    //   scheduleNotification(
    //       userId, // Passing the user's ID here
    //       medicineName,
    //       dosageAmount,
    //       validDoseTimes);
    // }

    Medicine? medicine =
        await DatabaseHelper.instance.getMedicineById(sqliteMedicineId);

    if (medicine != null) {
      List<TimeOfDay> doseTimesList = medicine.doseTimes;
      List<DateTime> validDoseTimes = [];

      for (TimeOfDay time in doseTimesList) {
        // Convert TimeOfDay to DateTime
        DateTime now = DateTime.now();
        DateTime doseDateTime =
            DateTime(now.year, now.month, now.day, time.hour, time.minute);
        validDoseTimes.add(doseDateTime);
      }

      print('Extracted Valid dose times now printing them');
      for (var dosetime in validDoseTimes) {
        print(dosetime);
      }

      print('Number of Doses: ${validDoseTimes.length}');
      print(
          'Medicine name from which notification is scheduled : $medicineName');
      print('dosage amount of the medicine : ${medicine.dosageAmount}');

      print('now calling scheduleNotification function');
      // Schedule the notification using the user's uuid to be used to make notification's unique identifier
      scheduleNotification(
        sqliteMedicineId,
        medicineName,
        medicine.dosageAmount,
        validDoseTimes,
      );
    }
  }

  void scheduleNotification(String id, String medicineName, String dosageAmount,
      List<DateTime> doseTimes) {
    print('reached inside scheduleNotification');
    // String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    // String uniqueString = id + timestamp;
    int baseId = id.hashCode;

    NotificationDetails notificationDetails = const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'Take medicine',
        icon: 'launcher_icon',
        color: Colors.deepPurple,
        styleInformation: BigTextStyleInformation(''),
      ),
    );
    for (var doseIndex = 0; doseIndex < doseTimes.length; doseIndex++) {
      var doseTime = doseTimes[
          doseIndex]; //getting the dosetime in the list for processing
      tz.TZDateTime notificationTime = convertToTZDateTime(
          doseTime); //converting the doseTime from DateTime to TZDateTime to be used in the zonedSchedule function
      int uniqueNotificationId =
          baseId + doseIndex; //creating a unique id for each notification
      _flutterLocalNotificationsPlugin.zonedSchedule(
        uniqueNotificationId,
        'Medicine Reminder',
        "It's time to take $medicineName ($dosageAmount)",
        notificationTime,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print(
          'Notification scheduled! id : $uniqueNotificationId notification time : $notificationTime');
    }
    print('out of for loop and at the end of scheduleNotification');
  }

  void updateNotification(String id, String medicineName, String dosageAmount,
      List<TimeOfDay> doseTimes) {
    cancelNotification(id);
    List<DateTime> newNotificationTimeList = convertToDateTimeList(doseTimes);
    scheduleNotification(
      id,
      medicineName,
      dosageAmount,
      newNotificationTimeList,
    );
    print("Notification Updated id : $id");
  }

  void cancelNotification(String medicineid) {
    /* Since we don't have a simple enough way to access the index of the dose to be cancelled,
     we cancel notifications for all indexes(1-10) even if those indexes do not exist.
     If they don't exist the cancel function won't do anything, so there's no downside except
     that time complexity will increase slightly. We can accept that for now for the
    sake of simplicity */
    // String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    // String uniqueString = medicineid + timestamp;
    int baseId = medicineid.hashCode;
    for (int i = 0; i < 10; i++) {
      int uniqueNotificationId = baseId + i;
      _flutterLocalNotificationsPlugin.cancel(uniqueNotificationId);
      print("Notification canceled id : $uniqueNotificationId");
    }
  }
}
