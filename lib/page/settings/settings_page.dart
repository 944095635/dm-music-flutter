import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dm_music/page/settings/settings_logic.dart';

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
        Container(
          width: 100,
          alignment: Alignment.centerLeft,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: Get.locale?.languageCode == "zh" ? 0 : 1,
            children: {
              0: Text("中文"),
              1: Text("English"),
            },
            onValueChanged: (value) {
              var locale = value == 0 ? Locale('zh', 'CN') : Locale('en', 'US');
              Get.updateLocale(locale);
            },
          ),
        ),

        Text("注:渐变模糊非常考验设备性能，如遇卡顿可切换为磨砂质感"),

        Container(
          width: 100,
          alignment: Alignment.centerLeft,
          child: CupertinoSlidingSegmentedControl<int>(
            // proportionalWidth: true,
            groupValue: controller.performanceMode ? 0 : 1,
            children: {
              0: Text("磨砂质感"),
              1: Text("渐变模糊"),
            },
            onValueChanged: (value) {
              controller.updatePerformanceMode(value == 0);
            },
          ),
        ),
      ],
    );
  }
}
