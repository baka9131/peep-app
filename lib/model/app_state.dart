import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:peep/model/data_model.dart';
import 'package:peep/repository/peep_repository.dart';
import 'package:peep/services/notification_service.dart';
import 'package:peep/services/settings_service.dart';

class AppState with ChangeNotifier {
  static final AppState _instance = AppState._();
  AppState._();
  factory AppState() => _instance;

  final PeepRepository _repository = PeepRepository();
  final NotificationService _notificationService = NotificationService();
  final SettingsService _settingsService = SettingsService();

  Future<void> initialize() async {
    await loadData();
  }

  int currentTabIndex = 0;
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

      // 먼저 오늘 체크인 상태 확인
      final todayStatus = await _repository.getTodayRecordStatus();
      if (todayStatus[RecordType.checkIn] ?? false) {
        errorMessage = '오늘 이미 체크인했습니다';
        return false;
      }

      final success = await _repository.addCheckIn();
      if (success) {
        await loadData();

        // 체크인 성공 시 오늘의 체크아웃 알림 스케줄
        try {
          final checkOutTime = await _settingsService.getCheckOutTime();
          final notificationEnabled = await _settingsService
              .getNotificationEnabled();

          if (notificationEnabled) {
            await _notificationService.scheduleCheckOutReminderForToday(
              checkOutTime,
            );
          }
        } catch (e) {
          debugPrint('체크아웃 알림 스케줄 실패: $e');
        }
      } else {
        // Repository에서 이미 체크했지만 추가 확인
        errorMessage = '오늘 이미 체크인했습니다';
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

      // 먼저 오늘 체크인/체크아웃 상태 확인
      final todayStatus = await _repository.getTodayRecordStatus();

      // 체크인 없이 체크아웃 시도
      if (!(todayStatus[RecordType.checkIn] ?? false)) {
        errorMessage = '먼저 체크인을 해주세요';
        return false;
      }

      // 이미 체크아웃한 경우
      if (todayStatus[RecordType.checkOut] ?? false) {
        errorMessage = '오늘 이미 체크아웃했습니다';
        return false;
      }

      final success = await _repository.addCheckOut();
      if (success) {
        await loadData();
      } else {
        // Repository에서 실패한 경우 적절한 메시지 설정
        final status = await _repository.getTodayRecordStatus();
        if (!(status[RecordType.checkIn] ?? false)) {
          errorMessage = '먼저 체크인을 해주세요';
        } else {
          errorMessage = '오늘 이미 체크아웃했습니다';
        }
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

  Future<bool> clearAllData() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final success = await _repository.clearAllData();
      if (success) {
        // 로컬 데이터 초기화
        dataList = [];
        dataMap = {};
        currentTabIndex = 0;
        errorMessage = null;
      } else {
        errorMessage = '데이터 초기화 실패';
      }
      return success;
    } catch (e) {
      errorMessage = '데이터 초기화 실패: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      return await _repository.getStatistics();
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
