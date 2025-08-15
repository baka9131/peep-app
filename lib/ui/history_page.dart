import 'package:flutter/material.dart';
import 'package:peep/common/enums.dart';
import 'package:peep/common/utils.dart';
import 'package:peep/common/widgets/in_out_card_widget.dart';
import 'package:peep/common/widgets/text_widgets.dart';
import 'package:peep/extension/extensions.dart';
import 'package:peep/model/data_model.dart';
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

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final records = dataMap[date] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDate(date),
            const SizedBox(height: 20),
            for (int index = 0; index < records.length; index++) ...[
              InOutCardWidget(
                type: (records[index].inout == 0) ? InOut.IN : InOut.OUT,
                title: dateDisplayString(records[index].dateTime),
                subtitle: (records[index].inout == 0) ? "체크인" : "체크아웃",
              ),
              const SizedBox(height: 20),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDate(DateTime date) {
    final textStyle = TextStyle(fontSize: 16, fontWeight: kFontWeightSemiBold);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomText(
          dateDisplayString(date, displayTime: false),
          style: textStyle,
        ),
      ],
    );
  }
}
