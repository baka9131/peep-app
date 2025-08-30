import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._();
  SettingsService._();
  factory SettingsService() => _instance;

  static const String _checkInHourKey = 'check_in_hour';
  static const String _checkInMinuteKey = 'check_in_minute';
  static const String _checkOutHourKey = 'check_out_hour';
  static const String _checkOutMinuteKey = 'check_out_minute';
  static const String _notificationEnabledKey = 'notification_enabled';

  // 기본값
  static const int defaultCheckInHour = 9;
  static const int defaultCheckInMinute = 0;
  static const int defaultCheckOutHour = 18;
  static const int defaultCheckOutMinute = 0;

  Future<TimeOfDay> getCheckInTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_checkInHourKey) ?? defaultCheckInHour;
    final minute = prefs.getInt(_checkInMinuteKey) ?? defaultCheckInMinute;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<TimeOfDay> getCheckOutTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_checkOutHourKey) ?? defaultCheckOutHour;
    final minute = prefs.getInt(_checkOutMinuteKey) ?? defaultCheckOutMinute;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> setCheckInTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_checkInHourKey, time.hour);
    await prefs.setInt(_checkInMinuteKey, time.minute);
  }

  Future<void> setCheckOutTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_checkOutHourKey, time.hour);
    await prefs.setInt(_checkOutMinuteKey, time.minute);
  }

  Future<bool> getNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? false;
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
  }
}
