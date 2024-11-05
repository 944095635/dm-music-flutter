import 'package:get/get.dart';

class Music {
  late String name;
  late String author;

  /// 封面
  late String cover;

  /// 音频链接源
  late String source;

  /// 收藏
  RxBool like = RxBool(false);
}
