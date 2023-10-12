//This file implmentation of all CRUD operations with cloud firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicinereminder/Services/Cloud/time_data_converter.dart';

final FirebaseFirestore _firestore =
    FirebaseFirestore.instance; //initializing firebase firestore
final CollectionReference _mainCollection = _firestore.collection(
    'Medicines'); //defining the main collection where all the database information will be stored

class Database {
  //this class contains all the crud functions
  //static String? userID = FirebaseAuth.instance.currentUser?.uid;
  static String? get userID => FirebaseAuth.instance.currentUser
      ?.uid; //current user's user id, that's auto-generated during authentication

  //Create
  static Future<void> addMedicine({
    required String medicineName,
    required String dosageAmount,
    required int frequency,
    required List<TimeOfDay?> doseTime,
    required String instructions,
    required String additionalInformation,
    required String uuid,
    required String? userID,
  }) async {
    DocumentReference documentReferencer =
        _mainCollection.doc(userID).collection('User-Medicines').doc();

    //below line converts the dosetime to firestore compatible format
    List<Map<String, int>> timesForFirestore =
        MedicineDataConverter.timeOfDayListToMapList(doseTime);

    Map<String, dynamic> medicine = {
      "Medicine Name": medicineName,
      "Dosage Amount": dosageAmount,
      "Frequency": frequency,
      "Date and Time": timesForFirestore,
      "Instructions": instructions,
      "Additional Information": additionalInformation,
      "uuid": uuid,
    };

    await documentReferencer
        .set(medicine)
        .whenComplete(() => print('Medicine added to the database'))
        .catchError((e) => print(e));
  }

  //Read
  static Stream<QuerySnapshot> readMedicine({required String? userID}) {
    return _mainCollection.doc(userID).collection('User-Medicines').snapshots();
    // CollectionReference medicineCollection =
    //     _mainCollection.doc(userID).collection('User-Medicines');

    // return medicineCollection.snapshots();
  }

  //Update
  static Future<void> updateMedicine({
    required String medicineName,
    required String dosageAmount,
    required int frequency,
    required List<TimeOfDay?> doseTime,
    required String instructions,
    required String additionalInformation,
    required String uuid,
    required String docID,
  }) async {
    DocumentReference documentReferencer =
        _mainCollection.doc(userID).collection('User-Medicines').doc(docID);

    List<Map<String, int>> timesForFirestore =
        MedicineDataConverter.timeOfDayListToMapList(doseTime);

    Map<String, dynamic> medicine = {
      "Medicine Name": medicineName,
      "Dosage Amount": dosageAmount,
      "Frequency": frequency,
      "Date and Time": timesForFirestore,
      "Instructions": instructions,
      "Additional Information": additionalInformation,
      "uuid": uuid,
    };

    await documentReferencer
        .update(medicine)
        .whenComplete(() => print('Medicine updated'));
    // .catchError((e) => print(e));
  }

  //Delete
  static Future<void> deleteMedicine({
    required String docID,
  }) async {
    DocumentReference documentReferencer =
        _mainCollection.doc(userID).collection('User-Medicines').doc(docID);

    await documentReferencer
        .delete()
        .whenComplete(() => print('Medicine Deleted'));
    // .catchError((e) => print((e)));
  }
}
