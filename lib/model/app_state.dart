import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:peep/model/data_model.dart';
import 'package:peep/repository/peep_repository.dart';

class AppState with ChangeNotifier {
  static final AppState _instance = AppState._();
  AppState._();
  factory AppState() => _instance;

  final PeepRepository _repository = PeepRepository();
  
  Future<void> initialize() async {
    await loadData();
  }

  int currentTabIndex = 0;
  int? autoCheck;
  List<DataModel> dataList = [];
  Map<DateTime, List<DataModel>> dataMap = {};
  bool isLoading = false;
  String? errorMessage;

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

  Future<void> loadData() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      dataList = await _repository.getAllRecords();
      dataMap = groupByDate();
    } catch (e) {
      errorMessage = '데이터 로드 실패: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCheckIn() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      final success = await _repository.addCheckIn();
      if (success) {
        await loadData();
      } else {
        errorMessage = '체크인 실패';
      }
      return success;
    } catch (e) {
      errorMessage = '체크인 실패: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCheckOut() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      final success = await _repository.addCheckOut();
      if (success) {
        await loadData();
      } else {
        errorMessage = '체크아웃 실패';
      }
      return success;
    } catch (e) {
      errorMessage = '체크아웃 실패: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRecord(int id) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      final success = await _repository.deleteRecord(id);
      if (success) {
        await loadData();
      } else {
        errorMessage = '삭제 실패';
      }
      return success;
    } catch (e) {
      errorMessage = '삭제 실패: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
