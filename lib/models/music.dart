import 'package:get/get.dart';

/// 音乐实体
class Music {
  /// 名称
  late String name;

  /// 作者
  String? author;

  /// 封面
  late String cover;

  /// 音频链接源
  String? source;

  /// 收藏
  RxBool like = RxBool(false);
}
