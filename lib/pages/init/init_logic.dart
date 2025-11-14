import 'package:dm_music/models/music_source.dart';
import 'package:dm_music/pages/home/home_page.dart';
import 'package:dm_music/services/app_service.dart';
import 'package:get/get.dart';

/// 初始化页面
class InitLogic extends GetxController {
  /// 选择的音乐数据源
  MusicSourceType? type;

  /// 更改音乐数据源
  void changeMusicSource(MusicSourceType newType) {
    type = newType;
    update();
  }

  /// 点击启动
  void onTapStart() {
    Get.find<AppService>().inited();
    Get.offAll(() => HomePage());
  }
}
