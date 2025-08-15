import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:peep/config/sqflite_config.dart';
import 'package:peep/model/data_model.dart';

class AppState with ChangeNotifier {
  static final AppState _instance = AppState._();
  AppState._();
  factory AppState() => _instance;

  Future<void> initialize() async {
    final database = SqfliteConfig.database;
    final records = await database?.rawQuery('SELECT * FROM PEEP');
    dataList = records?.map((e) => DataModel.fromJson(e)).toList() ?? [];
    dataMap = groupByDate();
  }

  int currentTabIndex = 0;
  int? autoCheck;
  List<DataModel> dataList = [];
  Map<DateTime, List<DataModel>> dataMap = {};

  Map<DateTime, List<DataModel>> groupByDate() {
    return groupBy(dataList, (e) {
      return DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day);
    });
  }

  void setCurrentIndex(int index) {
    currentTabIndex = index;
    notifyListeners();
  }

  void setAutoCheck(int? value) {
    autoCheck = value;
    notifyListeners();
  }

  void addRecord(String rawQuery) async {
    SqfliteConfig.database!.transaction((txn) async {
      await txn.rawInsert(rawQuery);
    });

    final database = SqfliteConfig.database;
    final records = await database?.rawQuery('SELECT * FROM PEEP');
    dataList = records?.map((e) => DataModel.fromJson(e)).toList() ?? [];
    dataList = dataList;
    dataMap = groupByDate();
    notifyListeners();
  }
}
