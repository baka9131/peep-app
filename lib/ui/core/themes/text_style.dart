import 'package:flutter/material.dart';
import 'package:peep/ui/core/themes/app_styles.dart';

/// Font weight.
const kFontWeightThin = FontWeight.w100;
const kFontWeightExtraLight = FontWeight.w200;
const kFontWeightLight = FontWeight.w300;
const kFontWeightRegular = FontWeight.w400;
const kFontWeightMedium = FontWeight.w500;
const kFontWeightSemiBold = FontWeight.w600;
const kFontWeightBold = FontWeight.w700;
const kFontWeightExtraBold = FontWeight.w800;
const kFontWeightBlack = FontWeight.w900;

/// Font sizes.
const kFontSizeXSmall = 11.0;
const kFontSizeSmall = 13.0;
const kFontSizeRegular = 14.0;
const kFontSizeMedium = 16.0;
const kFontSizeLarge = 18.0;
const kFontSizeXLarge = 20.0;
const kFontSizeXXLarge = 24.0;
const kFontSizeXXXLarge = 28.0;

/// Text style.
const kAppBarTextStyle = TextStyle(
  color: kColorBlack,
  fontFamily: 'Pretendard',
  fontSize: kFontSizeLarge,
  fontWeight: kFontWeightSemiBold,
  overflow: TextOverflow.ellipsis,
  letterSpacing: 0,
);

const kTitleTextStyle = TextStyle(
  color: kColorBlack,
  fontFamily: 'Pretendard',
  fontSize: kFontSizeXLarge,
  fontWeight: kFontWeightSemiBold,
  letterSpacing: 0,
);

const kSubtitleTextStyle = TextStyle(
  color: kColorGrey,
  fontFamily: 'Pretendard',
  fontSize: kFontSizeRegular,
  fontWeight: kFontWeightRegular,
  letterSpacing: 0,
);

const kBodyTextStyle = TextStyle(
  color: kColorBlack,
  fontFamily: 'Pretendard',
  fontSize: kFontSizeMedium,
  fontWeight: kFontWeightRegular,
  letterSpacing: 0,
);

const kButtonTextStyle = TextStyle(
  color: kColorWhite,
  fontFamily: 'Pretendard',
  fontSize: kFontSizeRegular,
  fontWeight: kFontWeightBold,
  letterSpacing: 0,
);

const kCaptionTextStyle = TextStyle(
  color: kColorGrey,
  fontFamily: 'Pretendard',
  fontSize: kFontSizeSmall,
  fontWeight: kFontWeightRegular,
  letterSpacing: 0,
);
