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
        await txn.insert('PEEP', {
          'inout': type.value,
          'dateTime': now.toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
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
        {'inout': type.value, 'dateTime': dateTime.toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );

      return count > 0;
    } catch (e) {
      print('Error updating record: $e');
      return false;
    }
  }

  Future<bool> clearAllData() async {
    try {
      final database = _database;
      if (database == null) {
        throw Exception('Database not initialized');
      }

      await database.transaction((txn) async {
        // PEEP 테이블의 모든 데이터 삭제
        await txn.delete('PEEP');
      });

      return true;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final database = _database;
      if (database == null) {
        throw Exception('Database not initialized');
      }

      final records = await getAllRecords();
      final totalRecords = records.length;

      // 날짜별로 그룹화
      final Map<DateTime, List<DataModel>> groupedRecords = {};
      for (var record in records) {
        final date = DateTime(
          record.dateTime.year,
          record.dateTime.month,
          record.dateTime.day,
        );
        groupedRecords.putIfAbsent(date, () => []);
        groupedRecords[date]!.add(record);
      }

      final totalDays = groupedRecords.keys.length;

      return {
        'totalRecords': totalRecords,
        'totalDays': totalDays,
        'firstRecord': records.isNotEmpty ? records.last : null,
        'lastRecord': records.isNotEmpty ? records.first : null,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {
        'totalRecords': 0,
        'totalDays': 0,
        'firstRecord': null,
        'lastRecord': null,
      };
    }
  }
}
