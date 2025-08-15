import 'package:flutter/material.dart';
import 'package:peep/common/widgets/text_widgets.dart';
import 'package:peep/ui/core/themes/text_style.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            "공사 중..",
            style: TextStyle(fontSize: 24, fontWeight: kFontWeightBold),
          ),
        ],
      ),
    );
  }
}
