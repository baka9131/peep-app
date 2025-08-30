import 'package:flutter_test/flutter_test.dart';
import 'package:peep/config/sqflite_config.dart';
import 'package:peep/repository/peep_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('PeepRepository Tests', () {
    late PeepRepository repository;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // 테스트용 인메모리 데이터베이스 사용
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await db.execute(
        'CREATE TABLE PEEP (id INTEGER PRIMARY KEY, inout INTEGER, dateTime TEXT)',
      );

      SqfliteConfig().setTestDatabase(db);
      repository = PeepRepository();
    });

    tearDown(() async {
      await SqfliteConfig().close();
    });

    test('addCheckIn should add a check-in record', () async {
      final result = await repository.addCheckIn();
      expect(result, true);

      final records = await repository.getAllRecords();
      expect(records.length, 1);
      expect(records.first.inout, 0);
    });

    test('addCheckOut should add a check-out record', () async {
      final result = await repository.addCheckOut();
      expect(result, true);

      final records = await repository.getAllRecords();
      expect(records.length, 1);
      expect(records.first.inout, 1);
    });

    test('getAllRecords should return all records', () async {
      await repository.addCheckIn();
      await repository.addCheckOut();

      final records = await repository.getAllRecords();
      expect(records.length, 2);
    });

    test('deleteRecord should remove a record', () async {
      await repository.addCheckIn();
      final records = await repository.getAllRecords();
      expect(records.length, 1);

      final id = records.first.id;
      final deleteResult = await repository.deleteRecord(id);
      expect(deleteResult, true);

      final remainingRecords = await repository.getAllRecords();
      expect(remainingRecords.length, 0);
    });

    test('updateRecord should modify existing record', () async {
      await repository.addCheckIn();
      final records = await repository.getAllRecords();
      final id = records.first.id;

      final newDate = DateTime(2024, 1, 1, 10, 0);
      final updateResult = await repository.updateRecord(
        id,
        RecordType.checkOut,
        newDate,
      );
      expect(updateResult, true);

      final updatedRecords = await repository.getAllRecords();
      expect(updatedRecords.first.inout, 1);
      expect(updatedRecords.first.dateTime.year, 2024);
    });
  });
}
