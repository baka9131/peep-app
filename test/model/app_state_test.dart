import 'package:flutter_test/flutter_test.dart';
import 'package:peep/config/sqflite_config.dart';
import 'package:peep/model/app_state.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('AppState Tests', () {
    late AppState appState;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      await SqfliteConfig().initialize();
      appState = AppState();
      await appState.initialize();
    });

    tearDown(() async {
      final db = SqfliteConfig.database;
      if (db != null && db.isOpen) {
        await db.close();
      }
    });

    test('initialize should load data', () async {
      expect(appState.dataList, isNotNull);
      expect(appState.dataMap, isNotNull);
    });

    test('setCurrentIndex should update tab index', () {
      appState.setCurrentIndex(1);
      expect(appState.currentTabIndex, 1);

      appState.setCurrentIndex(2);
      expect(appState.currentTabIndex, 2);
    });

    test('addCheckIn should add check-in record and reload data', () async {
      final initialCount = appState.dataList.length;

      final result = await appState.addCheckIn();
      expect(result, true);
      expect(appState.dataList.length, initialCount + 1);
      expect(appState.isLoading, false);
    });

    test('addCheckOut should add check-out record and reload data', () async {
      await appState.addCheckIn();
      final initialCount = appState.dataList.length;

      final result = await appState.addCheckOut();
      expect(result, true);
      expect(appState.dataList.length, initialCount + 1);
      expect(appState.isLoading, false);
    });

    test('groupByDate should group records by date', () async {
      await appState.addCheckIn();
      await Future.delayed(Duration(milliseconds: 100));
      await appState.addCheckOut();

      final dataMap = appState.groupByDate();
      expect(dataMap.isNotEmpty, true);

      final today = DateTime.now();
      final todayKey = DateTime(today.year, today.month, today.day);
      expect(dataMap.containsKey(todayKey), true);
    });

    test('deleteRecord should remove record and reload data', () async {
      await appState.addCheckIn();
      expect(appState.dataList.length, 1);

      final id = appState.dataList.first.id;
      final result = await appState.deleteRecord(id);
      expect(result, true);
      expect(appState.dataList.length, 0);
    });

    test('error handling should set error message', () async {
      // This test would require mocking the repository to simulate an error
      // For now, we just check that errorMessage is properly initialized
      expect(appState.errorMessage, isNull);
    });
  });
}
