// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peep/common/utils.dart';
import 'package:peep/common/widgets/text_widgets.dart';
import 'package:peep/extension/extensions.dart';
import 'package:peep/model/data_model.dart';
import 'package:peep/services/notification_service.dart';
import 'package:peep/ui/core/themes/app_styles.dart';
import 'package:peep/ui/core/themes/text_style.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationService _notificationService = NotificationService();
  @override
  Widget build(BuildContext context) {
    final state = context.watchAppState;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final Map<DateTime, List<DataModel>> dataMap = state.dataMap;
    final List<DataModel> todayRecords = dataMap[today] ?? [];

    final DataModel? firstRecord = todayRecords.firstWhereOrNull(
      (element) => element.inout == 0,
    );
    final DataModel? lastRecord = todayRecords.lastWhereOrNull(
      (element) => element.inout == 1,
    );

    // 근무 시간 계산
    Duration? workDuration;
    if (firstRecord != null && lastRecord != null) {
      workDuration = lastRecord.dateTime.difference(firstRecord.dateTime);
    } else if (firstRecord != null) {
      workDuration = DateTime.now().difference(firstRecord.dateTime);
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [kColorBlue.withValues(alpha: 0.05), Colors.white],
              stops: [0.0, 0.3],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  children: [
                    // 상태 카드
                    _buildStatusCard(firstRecord, lastRecord, workDuration),
                    const SizedBox(height: 24),

                    // 체크 버튼
                    _CheckButton(
                      isDiable:
                          (firstRecord != null && lastRecord != null) ||
                          state.isLoading,
                      title: getTitle(firstRecord, lastRecord),
                      onTap: () async => onTap(firstRecord, lastRecord),
                    ),

                    const SizedBox(height: 32),

                    // 오늘의 기록 섹션
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          "오늘의 기록",
                          style: TextStyle(
                            fontSize: kFontSizeLarge,
                            fontWeight: kFontWeightSemiBold,
                            color: kColorBlack,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kColorBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomText(
                            "${todayRecords.length}건",
                            style: TextStyle(
                              fontSize: kFontSizeSmall,
                              fontWeight: kFontWeightMedium,
                              color: kColorBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (todayRecords.isEmpty)
                      Container(
                        padding: EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_note_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            CustomText(
                              "오늘의 기록이 없습니다",
                              style: TextStyle(
                                fontSize: kFontSizeMedium,
                                fontWeight: kFontWeightMedium,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomText(
                              "체크인 버튼을 눌러 시작하세요",
                              style: TextStyle(
                                fontSize: kFontSizeSmall,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 기록 리스트
                    for (
                      int index = 0;
                      index < todayRecords.length;
                      index++
                    ) ...[
                      _buildRecordCard(todayRecords[index], index),
                      if (index < todayRecords.length - 1)
                        const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (state.isLoading)
          Container(
            color: Colors.black26,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kColorBlue),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusCard(
    DataModel? firstRecord,
    DataModel? lastRecord,
    Duration? workDuration,
  ) {
    String statusText = "출근 전";
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.home_outlined;

    if (firstRecord != null && lastRecord != null) {
      statusText = "퇴근 완료";
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else if (firstRecord != null) {
      statusText = "근무 중";
      statusColor = kColorBlue;
      statusIcon = Icons.work_outline;
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      statusText,
                      style: TextStyle(
                        fontSize: kFontSizeLarge,
                        fontWeight: kFontWeightSemiBold,
                        color: statusColor,
                      ),
                    ),
                    if (workDuration != null) ...[
                      const SizedBox(height: 4),
                      CustomText(
                        "근무 시간: ${workDuration.inHours}시간 ${workDuration.inMinutes % 60}분",
                        style: TextStyle(
                          fontSize: kFontSizeSmall,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (firstRecord != null || lastRecord != null) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeInfo(
                    "체크인",
                    firstRecord?.dateTime,
                    Icons.login,
                    Colors.blue,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[200]),
                Expanded(
                  child: _buildTimeInfo(
                    "체크아웃",
                    lastRecord?.dateTime,
                    Icons.logout,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfo(
    String label,
    DateTime? time,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            CustomText(
              label,
              style: TextStyle(
                fontSize: kFontSizeSmall,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        CustomText(
          time != null
              ? "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}"
              : "--:--",
          style: TextStyle(
            fontSize: kFontSizeMedium,
            fontWeight: kFontWeightSemiBold,
            color: time != null ? kColorBlack : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(DataModel record, int index) {
    final bool isCheckIn = record.inout == 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isCheckIn ? Colors.blue : Colors.orange).withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isCheckIn ? Icons.login : Icons.logout,
            color: isCheckIn ? Colors.blue : Colors.orange,
            size: 20,
          ),
        ),
        title: CustomText(
          isCheckIn ? "체크인" : "체크아웃",
          style: TextStyle(
            fontSize: kFontSizeMedium,
            fontWeight: kFontWeightMedium,
          ),
        ),
        subtitle: CustomText(
          dateDisplayString(record.dateTime),
          style: TextStyle(fontSize: kFontSizeSmall, color: Colors.grey[600]),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomText(
            "#${index + 1}",
            style: TextStyle(
              fontSize: kFontSizeXSmall,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  String getTitle(DataModel? checkin, DataModel? checkout) {
    if (checkin == null) {
      return "체크인";
    } else if (checkout == null) {
      return "체크아웃";
    }
    return "오늘 완료";
  }

  void onTap(DataModel? checkin, DataModel? checkout) async {
    if (checkin != null && checkout != null) return;

    // 햅틱 피드백 추가
    HapticFeedback.mediumImpact();

    final state = context.readAppState;
    bool success;

    if (checkin == null) {
      success = await state.addCheckIn();
    } else {
      success = await state.addCheckOut();
    }

    if (!mounted) return;

    if (!success && state.errorMessage != null) {
      // 실패 시 진동 피드백
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(state.errorMessage!)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (success) {
      // 성공 시 가벼운 진동 피드백
      HapticFeedback.lightImpact();
      final isCheckIn = checkin == null;

      // 성공 알림 전송
      try {
        if (isCheckIn) {
          await _notificationService.showCheckInSuccessNotification();
        } else {
          await _notificationService.showCheckOutSuccessNotification();
        }
      } catch (e) {
        // 알림 전송 실패해도 로그만 남기고 계속 진행
        debugPrint('알림 전송 실패: $e');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isCheckIn ? Icons.login : Icons.logout,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCheckIn ? '체크인 완료! 좋은 하루 보내세요 😊' : '체크아웃 완료! 수고하셨습니다 👏',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: isCheckIn ? Colors.blue : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

// ************************************************************************** //

class _CheckButton extends StatelessWidget {
  final String title;
  final Function() onTap;
  final bool isDiable;
  const _CheckButton({
    required this.onTap,
    required this.title,
    required this.isDiable,
  });

  @override
  Widget build(BuildContext context) {
    // 버튼 상태에 따른 색상 및 아이콘 설정
    Color buttonColor;
    Color borderColor;
    Color textColor;
    IconData buttonIcon;
    List<Color> gradientColors;

    if (isDiable) {
      // 완료 상태 (회색)
      buttonColor = Colors.grey[300]!;
      borderColor = Colors.grey[400]!;
      textColor = Colors.grey[600]!;
      buttonIcon = Icons.check_circle;
      gradientColors = [Colors.grey[300]!, Colors.grey[400]!];
    } else if (title == "체크인") {
      // 체크인 상태 (파란색)
      buttonColor = kColorBlue;
      borderColor = kColorBlue.withValues(alpha: 0.8);
      textColor = Colors.white;
      buttonIcon = Icons.login;
      gradientColors = [Color(0xFF4A90E2), Color(0xFF357ABD)];
    } else if (title == "체크아웃") {
      // 체크아웃 상태 (주황색)
      buttonColor = Colors.orange;
      borderColor = Colors.orange.withValues(alpha: 0.8);
      textColor = Colors.white;
      buttonIcon = Icons.logout;
      gradientColors = [Color(0xFFFF9800), Color(0xFFF57C00)];
    } else {
      // 기본 상태
      buttonColor = kColorBlue;
      borderColor = kColorBlue;
      textColor = Colors.white;
      buttonIcon = Icons.check_box_outlined;
      gradientColors = [kColorBlue, kColorBlue.withValues(alpha: 0.8)];
    }

    return GestureDetector(
      onTap: isDiable ? null : onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: isDiable
                ? null
                : LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isDiable ? buttonColor : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDiable
                  ? Colors.transparent
                  : borderColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: isDiable
                ? []
                : [
                    BoxShadow(
                      color: buttonColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDiable ? null : onTap,
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.white.withValues(alpha: 0.2),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(buttonIcon, color: textColor, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: kFontSizeMedium,
                        fontWeight: kFontWeightBold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (!isDiable) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: textColor.withValues(alpha: 0.7),
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
