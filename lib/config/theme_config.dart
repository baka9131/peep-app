import 'package:flutter/material.dart';
import 'package:peep/ui/core/themes/app_styles.dart';
import 'package:peep/ui/core/themes/text_style.dart';

class ThemeConfig {
  static ThemeData get theme {
    return ThemeData(
      fontFamily: 'Pretendard',

      colorScheme: const ColorScheme.light(
        surface: kColorWhite,
        primary: kColorBlack,
      ),

      appBarTheme: AppBarTheme(
        surfaceTintColor: kColorWhite,
        titleTextStyle: kAppBarTextStyle,
      ),
    );
  }
}
