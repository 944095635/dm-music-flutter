import 'package:intl/intl.dart';

class TimeUtils {
  /// 格式化时长
  /// [duration] 时长
  /// 将时长格式化为字符串，超过1小时则为 HH:mm:ss，否则为 mm:ss
  /// 例如 1小时30分钟20秒 -> 01:30:20
  /// 例如 10分钟20秒 -> 10:20
  static String formatTime(Duration duration) {
    final DateFormat format;
    if (duration.inHours >= 1) {
      // 超过1小时
      format = DateFormat("HH:mm:ss");
    } else {
      // 没有超过1小时
      format = DateFormat("mm:ss");
    }
    return format.format(
      DateTime.fromMillisecondsSinceEpoch(
        duration.inMilliseconds,
        isUtc: true,
      ),
    );
  }
}
