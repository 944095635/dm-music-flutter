import 'package:get/get.dart';
import 'package:dm_music/helper/cache_helper.dart';

class SettingsLogic extends GetxController {
  /// 性能模式
  var performanceMode = true;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  /// 初始化设置
  void init() async {
    performanceMode = await CacheHelper.getBool(.performanceMode) ?? true;
    update();
  }

  /// 更新模式
  void updatePerformanceMode(bool performanceMode) {
    this.performanceMode = performanceMode;
    CacheHelper.setBool(.performanceMode, performanceMode);
    update();
  }
}
