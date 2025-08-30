import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:peep/common/widgets/text_widgets.dart';
import 'package:peep/extension/extensions.dart';
import 'package:peep/model/data_model.dart';
import 'package:peep/ui/core/themes/app_styles.dart';
import 'package:peep/ui/core/themes/text_style.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final state = context.watchAppState;
    final Map<DateTime, List<DataModel>> dataMap = state.dataMap;

    // 날짜를 최신순으로 정렬
    final sortedDates = dataMap.keys.toList()..sort((a, b) => b.compareTo(a));

    // 전체 통계 계산
    int totalDays = sortedDates.length;
    int totalRecords = dataMap.values.fold(
      0,
      (sum, records) => sum + records.length,
    );

    if (sortedDates.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kColorBlue.withValues(alpha: 0.05), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              CustomText(
                "아직 기록이 없습니다",
                style: TextStyle(
                  fontSize: kFontSizeLarge,
                  fontWeight: kFontWeightMedium,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              CustomText(
                "홈 화면에서 체크인을 시작해보세요",
                style: TextStyle(
                  fontSize: kFontSizeMedium,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kColorBlue.withValues(alpha: 0.05), Colors.white],
          stops: [0.0, 0.2],
        ),
      ),
      child: Column(
        children: [
          // 통계 헤더
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.calendar_today,
                    label: "총 일수",
                    value: "$totalDays일",
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.format_list_numbered,
                    label: "총 기록",
                    value: "$totalRecords건",
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // 기록 리스트
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final records = dataMap[date] ?? [];

                // 해당 날짜의 첫 체크인과 마지막 체크아웃 찾기
                final firstCheckIn = records.firstWhereOrNull(
                  (r) => r.inout == 0,
                );
                final lastCheckOut = records.lastWhereOrNull(
                  (r) => r.inout == 1,
                );

                // 근무 시간 계산
                Duration? workDuration;
                if (firstCheckIn != null && lastCheckOut != null) {
                  workDuration = lastCheckOut.dateTime.difference(
                    firstCheckIn.dateTime,
                  );
                }

                return Container(
                  margin: EdgeInsets.only(bottom: 16),
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
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      childrenPadding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: kColorBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: CustomText(
                            "${date.day}",
                            style: TextStyle(
                              fontSize: kFontSizeLarge,
                              fontWeight: kFontWeightBold,
                              color: kColorBlue,
                            ),
                          ),
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            _getFormattedDate(date),
                            style: TextStyle(
                              fontSize: kFontSizeMedium,
                              fontWeight: kFontWeightSemiBold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              CustomText(
                                workDuration != null
                                    ? "${workDuration.inHours}시간 ${workDuration.inMinutes % 60}분"
                                    : "근무 시간 계산 불가",
                                style: TextStyle(
                                  fontSize: kFontSizeSmall,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: records.length.isEven
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CustomText(
                          "${records.length}건",
                          style: TextStyle(
                            fontSize: kFontSizeSmall,
                            fontWeight: kFontWeightMedium,
                            color: records.length.isEven
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                      children: [
                        Column(
                          children: [
                            for (int i = 0; i < records.length; i++) ...[
                              _buildRecordItem(records[i], i),
                              if (i < records.length - 1)
                                Divider(height: 16, color: Colors.grey[200]),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                label,
                style: TextStyle(
                  fontSize: kFontSizeSmall,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              CustomText(
                value,
                style: TextStyle(
                  fontSize: kFontSizeMedium,
                  fontWeight: kFontWeightSemiBold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(DataModel record, int index) {
    final bool isCheckIn = record.inout == 0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (isCheckIn ? Colors.blue : Colors.orange).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCheckIn ? Icons.login : Icons.logout,
              color: isCheckIn ? Colors.blue : Colors.orange,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  isCheckIn ? "체크인" : "체크아웃",
                  style: TextStyle(
                    fontSize: kFontSizeMedium,
                    fontWeight: kFontWeightMedium,
                  ),
                ),
                const SizedBox(height: 2),
                CustomText(
                  "${record.dateTime.hour.toString().padLeft(2, '0')}:${record.dateTime.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    fontSize: kFontSizeSmall,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomText(
              "#${index + 1}",
              style: TextStyle(
                fontSize: kFontSizeXSmall,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return "오늘";
    } else if (dateOnly == yesterday) {
      return "어제";
    } else {
      final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      return "${date.month}월 ${date.day}일 (${weekdays[date.weekday - 1]})";
    }
  }
}
