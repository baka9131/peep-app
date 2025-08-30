import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:peep/model/app_state.dart';
import 'package:peep/services/notification_service.dart';

class DeepLinkConfig {
  static final DeepLinkConfig _instance = DeepLinkConfig._();
  DeepLinkConfig._();
  factory DeepLinkConfig() => _instance;

  static StreamSubscription<Uri>? _linkSubscription;
  static StreamSubscription<Uri>? get linkSubscription => _linkSubscription;
  static GlobalKey<NavigatorState>? _navigatorKey;

  void initialize(
    BuildContext context, {
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    _navigatorKey = navigatorKey;

    _linkSubscription = AppLinks().uriLinkStream.listen((uri) async {
      debugPrint('uri: $uri');
      if (uri.hasScheme && uri.scheme == "sweeto" && uri.host == "peep") {
        if (uri.path.isEmpty) return;

        // 잠깐 기다려서 MaterialApp이 완전히 로드되도록 함
        await Future.delayed(const Duration(milliseconds: 500));

        switch (uri.path) {
          case '/checkin':
            await _performDeepLinkCheckIn();
            break;
          case '/checkout':
            await _performDeepLinkCheckOut();
            break;
        }
      }
    });
  }

  Future<void> _performDeepLinkCheckIn() async {
    try {
      final state = AppState();
      final success = await state.addCheckIn();

      final context = _navigatorKey?.currentContext;
      if (context != null && context.mounted) {
        if (success) {
          // 홈 탭으로 이동
          state.setCurrentIndex(0);

          // 성공 알림 전송
          try {
            await NotificationService().showCheckInSuccessNotification();
          } catch (e) {
            debugPrint('QR 체크인 알림 전송 실패: $e');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.login, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'QR로 체크인 완료! 좋은 하루 보내세요 😊',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.errorMessage ?? '체크인 실패')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // context가 없을 때는 알림만 전송
        if (success) {
          try {
            await NotificationService().showCheckInSuccessNotification();
          } catch (e) {
            debugPrint('QR 체크인 알림 전송 실패: $e');
          }
        }
        debugPrint('QR 체크인 ${success ? "성공" : "실패"}: context 없음');
      }
    } catch (e) {
      debugPrint('QR 체크인 오류: $e');
    }
  }

  Future<void> _performDeepLinkCheckOut() async {
    try {
      final state = AppState();

      // 먼저 오늘 체크인했는지 확인
      await state.loadData(); // 최신 데이터 로드
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayRecords = state.dataMap[today] ?? [];

      // 오늘 체크인 기록이 있는지 확인
      final hasCheckInToday = todayRecords.any((record) => record.inout == 0);

      if (!hasCheckInToday) {
        // 체크인 없이 체크아웃 시도
        debugPrint('체크인 없이 체크아웃 시도됨');

        final context = _navigatorKey?.currentContext;
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '먼저 체크인을 해주세요',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final success = await state.addCheckOut();

      final context = _navigatorKey?.currentContext;
      if (context != null && context.mounted) {
        if (success) {
          // 홈 탭으로 이동
          state.setCurrentIndex(0);

          // 성공 알림 전송
          try {
            await NotificationService().showCheckOutSuccessNotification();
          } catch (e) {
            debugPrint('QR 체크아웃 알림 전송 실패: $e');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.logout, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'QR로 체크아웃 완료! 수고하셨습니다 👏',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.errorMessage ?? '체크아웃 실패')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // context가 없을 때는 알림만 전송
        if (success) {
          try {
            await NotificationService().showCheckOutSuccessNotification();
          } catch (e) {
            debugPrint('QR 체크아웃 알림 전송 실패: $e');
          }
        }
        debugPrint('QR 체크아웃 ${success ? "성공" : "실패"}: context 없음');
      }
    } catch (e) {
      debugPrint('QR 체크아웃 오류: $e');
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
