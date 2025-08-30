import 'package:peep/config/sqflite_config.dart';
import 'package:peep/model/data_model.dart';
import 'package:sqflite/sqflite.dart';

enum RecordType {
  checkIn(0),
  checkOut(1);

  final int value;
  const RecordType(this.value);
}

class PeepRepository {
  static final PeepRepository _instance = PeepRepository._();
  PeepRepository._();
  factory PeepRepository() => _instance;

  Database? get _database => SqfliteConfig.database;

  Future<List<DataModel>> getAllRecords() async {
    try {
      final database = _database;
      if (database == null) {
        throw Exception('Database not initialized');
      }

      final records = await database.query('PEEP', orderBy: 'dateTime DESC');
      return records.map((e) => DataModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching records: $e');
      return [];
    }
  }

  Future<bool> addCheckIn() async {
    return _addRecord(RecordType.checkIn);
  }

  Future<bool> addCheckOut() async {
    return _addRecord(RecordType.checkOut);
  }

  Future<bool> _addRecord(RecordType type) async {
    try {
      final database = _database;
      if (database == null) {
        throw Exception('Database not initialized');
      }

      final now = DateTime.now();
      
      await database.transaction((txn) async {
        await txn.insert(
          'PEEP',
          {
            'inout': type.value,
            'dateTime': now.toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });

      return true;
    } catch (e) {
      print('Error adding record: $e');
      return false;
    }
  }

  Future<bool> deleteRecord(int id) async {
    try {
      final database = _database;
      if (database == null) {
        throw Exception('Database not initialized');
      }

      final count = await database.delete(
        'PEEP',
        where: 'id = ?',
        whereArgs: [id],
      );

      return count > 0;
    } catch (e) {
      print('Error deleting record: $e');
      return false;
    }
  }

  Future<bool> updateRecord(int id, RecordType type, DateTime dateTime) async {
    try {
      final database = _database;
      if (database == null) {
        throw Exception('Database not initialized');
      }

      final count = await database.update(
        'PEEP',
        {
          'inout': type.value,
          'dateTime': dateTime.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      return count > 0;
    } catch (e) {
      print('Error updating record: $e');
      return false;
    }
  }
}