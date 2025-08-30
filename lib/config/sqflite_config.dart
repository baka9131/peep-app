import 'package:sqflite/sqflite.dart';

class SqfliteConfig {
  static final SqfliteConfig _instance = SqfliteConfig._();
  SqfliteConfig._();
  factory SqfliteConfig() => _instance;

  static Database? _database;
  static Database? get database => _database;

  /// 초기화.
  Future<void> initialize({String? testPath}) async {
    if (testPath != null) {
      // 테스트용 데이터베이스
      _database = await openDatabase(
        testPath,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
            'CREATE TABLE PEEP (id INTEGER PRIMARY KEY, inout INTEGER, dateTime TEXT)',
          );
        },
      );
    } else {
      // 실제 데이터베이스
      _database = await openDatabase(
        'peep.db',
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
            'CREATE TABLE PEEP (id INTEGER PRIMARY KEY, inout INTEGER, dateTime TEXT)',
          );
        },
      );
    }
  }

  /// 테스트용 데이터베이스 설정
  void setTestDatabase(Database db) {
    _database = db;
  }

  /// 데이터베이스 닫기
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
