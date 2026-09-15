import 'dart:ui';
import 'package:get/get.dart';
import 'package:dm_music/helper/cache_helper.dart';
import 'package:dm_music/service/app_service.dart';

class SettingsLogic extends GetxController {
  /// 更新语言
  void updateLanguage(String? language) {
    if (language == null) return;
    var locale = language == 'zh' ? Locale('zh', 'CN') : Locale('en', 'US');
    // 保存到本地配置
    CacheHelper.setString(.language, language);
    Get.updateLocale(locale);
  }

  /// 更新模式
  void updatePerformanceMode(bool? performanceMode) {
    if (performanceMode == null) return;
    AppService.performanceMode = performanceMode;
    CacheHelper.setBool(.performanceMode, performanceMode);
    Get.forceAppUpdate();
  }
}
