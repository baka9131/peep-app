import 'package:sqflite/sqflite.dart';

class SqfliteConfig {
  static final SqfliteConfig _instance = SqfliteConfig._();
  SqfliteConfig._();
  factory SqfliteConfig() => _instance;

  static Database? _database;
  static Database? get database => _database;

  /// 초기화.
  Future<void> initialize() async {
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
