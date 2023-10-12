import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medicinereminder/Notifications/SQLite/Utility/time_of_day_utils.dart';
import 'package:medicinereminder/Notifications/SQLite/medicine_model_for_sqlite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "LocalMedicineForNotifications.db";
  static const _databaseVersion = 1;

  // Singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS medicine(
      id TEXT PRIMARY KEY,
        medicine_name TEXT NOT NULL,
        dosage_amount TEXT NOT NULL,
        dose_times TEXT
    ); 
    ''');
  }

  //CRUD ===>>

  // For inserting new medicine into the database
  // create
  Future<int> insertMedicine({
    required String id,
    required String medicineName,
    required String dosageAmount,
    required List<TimeOfDay> doseTimes,
  }) async {
    Database db = await instance.database;
    Map<String, dynamic> row = {
      'id': id,
      'medicine_name': medicineName,
      'dosage_amount': dosageAmount,
      'dose_times': doseTimes.map(TimeOfDayUtils.serializeTimeOfDay).join(","),
    };
    return await db.insert('medicine', row);
  }

  // Future<int> insertMedicine(Medicine medicine) async {
  //   Database db = await instance.database;
  //   return await db.insert('medicine', medicine.toMap());
  // }

  // For retrieving all medicines
  //read
  Future<List<Medicine>> queryAllMedicines() async {
    Database db = await instance.database;
    List<Map> maps = await db.query('medicine');
    return maps
        .map((e) => Medicine.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  //update
  Future<int> updateMedicine({
    required String id,
    required String medicineName,
    required String dosageAmount,
    required List<TimeOfDay> doseTimes,
  }) async {
    Database db = await instance.database;
    Map<String, dynamic> row = {
      'medicine_name': medicineName,
      'dosage_amount': dosageAmount,
      'dose_times': doseTimes.map(TimeOfDayUtils.serializeTimeOfDay).join(","),
    };
    return await db.update('medicine', row, where: 'id = ?', whereArgs: [id]);
  }

  // Future<int> updateMedicine(Medicine medicine) async {
  //   Database db = await instance.database;
  //   return await db.update('medicine', medicine.toMap(),
  //       where: 'id = ?', whereArgs: [medicine.id]);
  // }

  //delete
  Future<int> deleteMedicine(String id) async {
    Database db = await instance.database;
    return await db.delete(
      'medicine',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Medicine?> getMedicineById(String medicineId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db
        .query('medicine', where: 'medicine_name = ?', whereArgs: [medicineId]);
    if (result.isNotEmpty) {
      return Medicine.fromMap(result.first);
    }
    return null;
  }
}
