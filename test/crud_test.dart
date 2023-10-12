import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicinereminder/Services/Cloud/crud_cloud_firestore.dart';
import 'package:medicinereminder/Services/Cloud/time_data_converter.dart';

void main() {
  group('Mock CRUD operations', () {
    final database = MockDatabase();

    test("Should be able to add medicine", () async {
      await database.addMedicine(
        medicineName: "Test Medicine",
        dosageAmount: "1 tablet",
        frequency: 1,
        doseTime: [const TimeOfDay(hour: 10, minute: 00)],
        instructions: "After meals",
        additionalInformation: "store in cool place",
        userID: "TestUserID",
      );

      expect(database.medicinesList.length, 1);
      expect(database.medicinesList[0]["Medicine Name"], "Test Medicine");
      expect(database.medicinesList[0]["Dosage Amount"], "1 tablet");
      expect(database.medicinesList[0]["Frequency"], 1);
      expect(database.medicinesList[0]["Date and Time"], [
        {'hour': 10, 'minute': 0}
      ]);

      expect(database.medicinesList[0]["Instructions"], "After meals");
      expect(database.medicinesList[0]["Additional Information"],
          "store in cool place");
    });

    test("should emit correct medicine data for a valid userID", () async {
      database._medicinesList.clear();
      database._docIDToIndexMap.clear();
      const userID = "TestUserID";
      final Map<String, dynamic> expectedMedicine = {
        "Medicine Name": "TestMedicine",
        "Dosage Amount": "1 tablet",
        "Frequency": 1,
        "Date and Time": [
          {const TimeOfDay(hour: 10, minute: 00)}
        ],
        "Instructions": "After meals",
        "Additional Information": "store in cool place",
      };
      // Add the medicine to your mock database
      database._medicinesList.add(expectedMedicine);
      database._docIDToIndexMap[userID] = database._medicinesList.length - 1;

      // Now, test the readMedicine function
      await expectLater(
        database.readMedicine(userID: userID),
        emitsInOrder([
          [expectedMedicine], // Expect a list containing the added medicine
          emitsDone
        ]),
      );
    });

    // test("should emit empty list for an invalid userID", () async {
    //   final userID = "invalidUserID";

    //   await expectLater(
    //       database.readMedicine(userID: userID),
    //       emitsInOrder([
    //         [], // Expect an empty list
    //         emitsDone
    //       ])
    //       //emitsError(isA<MedicineNotFoundException>())
    //       );
    // });

    test("should be able to update medicine", () async {
      await database.updateMedicine(
        medicineName: "New Medicine Name",
        dosageAmount: "2 tablets",
        frequency: 2,
        doseTime: [const TimeOfDay(hour: 5, minute: 00)],
        instructions: "before meals",
        additionalInformation: "nil",
        docID: "TestUserID",
      );

      expect(database.medicinesList.length, 1);
      expect(database.medicinesList[0]["Medicine Name"], "New Medicine Name");
      expect(database.medicinesList[0]["Dosage Amount"], "2 tablets");
      expect(database.medicinesList[0]["Frequency"], 2);
      expect(database.medicinesList[0]["Date and Time"], [
        {'hour': 5, 'minute': 00}
      ]);
      expect(database.medicinesList[0]["Instructions"], "before meals");
      expect(database.medicinesList[0]["Additional Information"], "nil");
    });

    test("medicine not found during updation", () async {
      await database.updateMedicine(
        medicineName: "New Medicine Name",
        dosageAmount: "2 tablets",
        frequency: 2,
        doseTime: [const TimeOfDay(hour: 05, minute: 00)],
        instructions: "before meals",
        additionalInformation: "nil",
        docID: "TestUserID",
      );

      expect(
          () => database.updateMedicine(
                docID: "InvalidUserID",
                medicineName: "New Medicine Name",
                dosageAmount: "2 tablets",
                frequency: 2,
                doseTime: [const TimeOfDay(hour: 05, minute: 00)],
                instructions: "before meals",
                additionalInformation: "nil",
              ),
          throwsA(isA<MedicineNotFoundException>()));
    });

    test('deleteMedicine should remove a medicine correctly', () async {
      database._medicinesList.clear();
      database._docIDToIndexMap.clear();
      // Add medicines
      const String userID1 = "user1";
      const String userID2 = "user2";
      const String userID3 = "user3";

      await database.addMedicine(
          medicineName: "User1 Medicine",
          dosageAmount: "1 tablet",
          frequency: 2,
          doseTime: [const TimeOfDay(hour: 7, minute: 00)],
          instructions: "After meals",
          additionalInformation: "store in cool place",
          userID: userID1);
      await database.addMedicine(
          medicineName: "User2 Medicine",
          dosageAmount: "2 tablet",
          frequency: 1,
          doseTime: [const TimeOfDay(hour: 10, minute: 00)],
          instructions: "before meals",
          additionalInformation: "store in dark place",
          userID: userID2);
      await database.addMedicine(
          medicineName: "User3 Medicine",
          dosageAmount: "1 tablet",
          frequency: 3,
          doseTime: [const TimeOfDay(hour: 04, minute: 30)],
          instructions: "with warm water",
          additionalInformation: "store in dry place",
          userID: userID3);

      // Now, let's delete the medicine with userID2.
      await database.deleteMedicine(docID: userID2);

      // After deleting, if we try to get the medicine with userID2, it should not exist.
      await expectLater(
        database.readMedicine(userID: userID2),
        emitsError(isA<MedicineNotFoundException>()),
      );

      // Moreover, if you have userID3 whose index was (say) 2 before, its index should now be 1.
      // So, when you try to read the medicine using userID3, it should give you the data at index 1 of _medicinesList.
      final medicines = await database.readMedicine(userID: userID3).first;
      expect(medicines[0], database._medicinesList[1]);

      // Let's try to delete userID2 again; it should throw an error since it doesn't exist anymore.
      expect(() => database.deleteMedicine(docID: userID2),
          throwsA(isA<MedicineNotFoundException>()));
    });
  });
}

//exceptions
class MedicineNotFoundException implements Exception {}

class UserNotFoundException implements Exception {}

class MockDatabase extends Database {
  final List<Map<String, dynamic>> _medicinesList = [];
  List<Map<String, dynamic>> get medicinesList => _medicinesList;

  final Map<String?, int> _docIDToIndexMap = {};

  Future<void> addMedicine({
    required String medicineName,
    required String dosageAmount,
    required int frequency,
    required List<TimeOfDay?> doseTime,
    required String instructions,
    required String additionalInformation,
    required String? userID,
  }) async {
    List<Map<String, int>> timesForFirestore =
        MedicineDataConverter.timeOfDayListToMapList(doseTime);

    Map<String, dynamic> medicine = {
      "Medicine Name": medicineName,
      "Dosage Amount": dosageAmount,
      "Frequency": frequency,
      "Date and Time": timesForFirestore,
      "Instructions": instructions,
      "Additional Information": additionalInformation,
    };

    await Future.delayed(const Duration(seconds: 1));

    _medicinesList.add(medicine);
    _docIDToIndexMap[userID] = _medicinesList.length - 1;
  }

  Stream<List<Map<String, dynamic>>> readMedicine({required String userID}) {
    final streamController = StreamController<List<Map<String, dynamic>>>();

    // This simulates some database delay
    Future.delayed(const Duration(milliseconds: 500), () {
      int? index = _docIDToIndexMap[userID];

      if (index != null) {
        //streamController.add([]); // Empty list indicating no data
        streamController.add([_medicinesList[index]]);
      } else {
        streamController.addError(MedicineNotFoundException());
        //streamController.close();
      }
      streamController.close();
    });

    return streamController.stream;
  }

  Future<void> updateMedicine({
    required String medicineName,
    required String dosageAmount,
    required int frequency,
    required List<TimeOfDay?> doseTime,
    required String instructions,
    required String additionalInformation,
    required String docID,
  }) async {
    List<Map<String, int>> timesForFirestore =
        MedicineDataConverter.timeOfDayListToMapList(doseTime);

    Map<String, dynamic> medicine = {
      "Medicine Name": medicineName,
      "Dosage Amount": dosageAmount,
      "Frequency": frequency,
      "Date and Time": timesForFirestore,
      "Instructions": instructions,
      "Additional Information": additionalInformation,
    };

    await Future.delayed(const Duration(seconds: 1));

    //updating the correct index of _medicinesList
    int? indexToUpdate = _docIDToIndexMap[docID];
    if (indexToUpdate != null) {
      _medicinesList[indexToUpdate] = medicine;
    } else {
      throw MedicineNotFoundException();
    }
  }

  Future<void> deleteMedicine({required String docID}) async {
    // Step 1: Retrieve the index from the map using docID
    int? index = _docIDToIndexMap[docID];

    if (index == null) {
      throw MedicineNotFoundException(); // throw an exception when the medicine is not found
    }

    // Step 2: Remove the medicine from _medicinesList
    _medicinesList.removeAt(index);

    // Adjust indices in the map for all items after the removed item
    for (var key in _docIDToIndexMap.keys) {
      if (_docIDToIndexMap[key]! > index) {
        _docIDToIndexMap[key] = _docIDToIndexMap[key]! - 1;
      }
    }

    // Step 3: Remove the docID from the map
    _docIDToIndexMap.remove(docID);

    await Future.delayed(const Duration(seconds: 1));
    //print('Medicine with docID: $docID deleted.');
  }
}
