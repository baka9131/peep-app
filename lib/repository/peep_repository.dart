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
    // 오늘 이미 체크인했는지 확인
    final hasCheckedInToday = await _hasRecordToday(RecordType.checkIn);
    if (hasCheckedInToday) {
      print('오늘 이미 체크인했습니다');
      return false;
    }
    return _addRecord(RecordType.checkIn);
  }

  Future<bool> addCheckOut() async {
    // 오늘 체크인했는지 먼저 확인
    final hasCheckedInToday = await _hasRecordToday(RecordType.checkIn);
    if (!hasCheckedInToday) {
      print('체크인 없이 체크아웃할 수 없습니다');
      return false;
    }
    
    // 오늘 이미 체크아웃했는지 확인
    final hasCheckedOutToday = await _hasRecordToday(RecordType.checkOut);
    if (hasCheckedOutToday) {
      print('오늘 이미 체크아웃했습니다');
      return false;
    }
    return _addRecord(RecordType.checkOut);
  }

  Future<bool> _hasRecordToday(RecordType type) async {
    try {
      final database = _database;
      if (database == null) {
        throw Exception('Database not initialized');
      }

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final records = await database.query(
        'PEEP',
        where: 'inout = ? AND dateTime >= ? AND dateTime < ?',
        whereArgs: [
          type.value,
          todayStart.toIso8601String(),
          todayEnd.toIso8601String(),
        ],
      );

      return records.isNotEmpty;
    } catch (e) {
      print('Error checking today record: $e');
      return false;
    }
  }

  Future<Map<RecordType, bool>> getTodayRecordStatus() async {
    try {
      final database = _database;
      if (database == null) {
        throw Exception('Database not initialized');
      }

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final records = await database.query(
        'PEEP',
        where: 'dateTime >= ? AND dateTime < ?',
        whereArgs: [
          todayStart.toIso8601String(),
          todayEnd.toIso8601String(),
        ],
      );

      bool hasCheckIn = false;
      bool hasCheckOut = false;

      for (final record in records) {
        final inout = record['inout'] as int;
        if (inout == RecordType.checkIn.value) {
          hasCheckIn = true;
        } else if (inout == RecordType.checkOut.value) {
          hasCheckOut = true;
        }
      }

      return {
        RecordType.checkIn: hasCheckIn,
        RecordType.checkOut: hasCheckOut,
      };
    } catch (e) {
      print('Error getting today record status: $e');
      return {
        RecordType.checkIn: false,
        RecordType.checkOut: false,
      };
    }
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
