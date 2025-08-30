// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:peep/common/enums.dart';
import 'package:peep/common/utils.dart';
import 'package:peep/common/widgets/in_out_card_widget.dart';
import 'package:peep/common/widgets/text_widgets.dart';
import 'package:peep/extension/extensions.dart';
import 'package:peep/model/data_model.dart';
import 'package:peep/ui/core/themes/app_styles.dart';
import 'package:peep/ui/core/themes/text_style.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                children: [
                  _CheckButton(
                    isDiable: (firstRecord != null && lastRecord != null) || state.isLoading,
                    title: getTitle(firstRecord, lastRecord),
                    onTap: () async => onTap(firstRecord, lastRecord),
                  ),
              const SizedBox(height: 30),
              CustomText(
                "Today",
                style: TextStyle(fontSize: 20, fontWeight: kFontWeightSemiBold),
              ),
              const SizedBox(height: 30),
              if (todayRecords.isEmpty)
                Center(
                  child: CustomText(
                    "오늘의 기록을 시작해보세요.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),

              for (int index = 0; index < todayRecords.length; index++) ...[
                InOutCardWidget(
                  type: (todayRecords[index].inout == 0) ? InOut.IN : InOut.OUT,
                  title: dateDisplayString(todayRecords[index].dateTime),
                  subtitle: (todayRecords[index].inout == 0) ? "체크인" : "체크아웃",
                ),
                if (todayRecords.length > 1) const SizedBox(height: 20),
              ],
                ],
              ),
            ),
          ],
        ),
        if (state.isLoading)
          Container(
            color: Colors.black26,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  String getTitle(DataModel? checkin, DataModel? checkout) {
    if (checkin == null) {
      return "체크인";
    } else if (checkout == null) {
      return "체크아웃";
    }
    return "완료";
  }

  void onTap(DataModel? checkin, DataModel? checkout) async {
    if (checkin != null && checkout != null) return;

    final state = context.readAppState;
    bool success;

    if (checkin == null) {
      success = await state.addCheckIn();
    } else {
      success = await state.addCheckOut();
    }

    if (!mounted) return;

    if (!success && state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    } else if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(checkin == null ? '체크인 완료' : '체크아웃 완료'),
          backgroundColor: Colors.green,
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
    final textStyle = TextStyle(
      color: kColorWhite,
      fontSize: 14,
      fontWeight: kFontWeightBold,
    );

    return InkWell(
      onTap: isDiable ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDiable ? kColorGrey : kColorBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Icon(Icons.check_box_outlined, color: kColorWhite),
            CustomText(title, style: textStyle),
          ],
        ),
      ),
    );
  }
}
