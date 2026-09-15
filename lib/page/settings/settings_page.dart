import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dm_music/page/settings/settings_logic.dart';
import 'package:dm_music/page/settings/settings_title_item.dart';
import 'package:dm_music/service/app_service.dart';

/// 设置页面
class SettingsPage extends GetView<SettingsLogic> {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("settings".tr),
      ),
      body: GetBuilder<SettingsLogic>(
        init: SettingsLogic(), // 注册设置逻辑
        builder: (controller) => buildBody(),
      ),
    );
  }

  /// 构建主体
  Widget buildBody() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        SettingsTitleItem("language".tr),
        Align(
          alignment: Alignment.centerLeft,
          child: CupertinoSlidingSegmentedControl<String>(
            groupValue: Get.locale?.languageCode,
            children: {
              "zh": Text("中文"),
              "en": Text("English"),
            },
            onValueChanged: controller.updateLanguage,
          ),
        ),

        SizedBox(height: 20),

        SettingsTitleItem(
          "performance_mode".tr,
          subTitle: "performance_mode_note".tr,
        ),

        Align(
          alignment: Alignment.centerLeft,
          child: CupertinoSlidingSegmentedControl<bool>(
            // proportionalWidth: true,
            groupValue: AppService.performanceMode,
            children: {
              true: Text("performance_mode_1".tr),
              false: Text("performance_mode_2".tr),
            },
            onValueChanged: controller.updatePerformanceMode,
          ),
        ),
      ],
    );
  }
}
