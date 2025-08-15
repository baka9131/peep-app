import 'package:flutter/material.dart';
import 'package:peep/common/enums.dart';
import 'package:peep/common/widgets/text_widgets.dart';
import 'package:peep/ui/core/themes/app_styles.dart';
import 'package:peep/ui/core/themes/text_style.dart';

class BasicCardWidget extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  const BasicCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: kColorGrey1,
            borderRadius: BorderRadius.circular(6),
          ),
          child: icon,
        ),
        const SizedBox(width: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              title,
              style: TextStyle(fontSize: 14, fontWeight: kFontWeightSemiBold),
            ),
            CustomText(
              subtitle,
              style: TextStyle(fontSize: 12, color: kColorGrey),
            ),
          ],
        ),
      ],
    );
  }
}

// ************************************************************************** //

class InOutCardWidget extends StatelessWidget {
  final InOut type;
  final String title;
  final String subtitle;

  const InOutCardWidget({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final icon = type == InOut.IN
        ? Icon(Icons.arrow_back)
        : Icon(Icons.arrow_forward);

    return BasicCardWidget(icon: icon, title: title, subtitle: subtitle);
  }
}
