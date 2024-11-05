import 'package:intl/intl.dart';

extension DurationUtils on Duration {
  String format() {
    DateFormat format;
    if (inHours >= 1) {
      //超过1小时
      format = DateFormat("HH:mm:ss");
    } else {
      //没有超过1小时
      format = DateFormat("mm:ss");
    }
    return format.format(
      DateTime.fromMillisecondsSinceEpoch(
        inMilliseconds,
        isUtc: true,
      ),
    );
  }
}
