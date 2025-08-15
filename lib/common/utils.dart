// 날짜 String format
import 'package:intl/intl.dart' as intl;

String dateDisplayString(
  DateTime? date, {
  String? defaultText,
  bool displayTime = true,
}) {
  if (date == null && defaultText != null) {
    return defaultText;
  }
  try {
    intl.DateFormat format = dateDisplayFormat();
    if (displayTime) format = format.add_jm();
    return format.format(date!);
  } catch (e) {
    return "";
  }
}

intl.DateFormat dateDisplayFormat() {
  try {
    String? string = intl.Intl.defaultLocale;
    return intl.DateFormat.yMMMMd(string);
  } on ArgumentError {
    return intl.DateFormat.yMMMMd();
  }
}
