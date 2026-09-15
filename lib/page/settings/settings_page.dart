import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 设置页面
class SettingsPage extends StatefulWidget {
  const new({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("settings".tr),
      ),
      body: buildBody(),
    );
  }

  /// 构建主体
  Widget buildBody() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        CupertinoSlidingSegmentedControl<int>(
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

        Text("注:渐变模糊非常考验设备性能，如遇卡顿可切换为磨砂质感"),

        CupertinoSlidingSegmentedControl<int>(
          groupValue: 0,
          children: {
            0: Text("磨砂质感"),
            1: Text("渐变模糊"),
          },
          onValueChanged: (value) {},
        ),
      ],
    );
  }
}
