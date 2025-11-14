import 'package:dm_music/models/music_source.dart';
import 'package:dm_music/pages/home/home_page.dart';
import 'package:dm_music/services/app_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// 初始化页面
class InitLogic extends GetxController {
  /// 选择的音乐数据源
  MusicSourceType? type;

  /// 输入OK
  bool inputOK = false;

  final serverController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    serverController.addListener(updateInputState);
    usernameController.addListener(updateInputState);
    passwordController.addListener(updateInputState);
  }

  @override
  void onClose() {
    serverController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// 更改音乐数据源
  void changeMusicSource(MusicSourceType newType) {
    type = newType;
    updateInputState();
  }

  /// 更新输入状态
  void updateInputState() {
    if (type == MusicSourceType.dmusic) {
      inputOK = true;
    } else if (serverController.text.isNotEmpty &&
        usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      inputOK = true;
    } else {
      inputOK = false;
    }
    update();
  }

  /// 点击启动
  void onTapStart() {
    if (type == MusicSourceType.dmusic) {
      Get.find<AppService>().inited();
      Get.offAll(() => HomePage());
    } else {
      Get.snackbar("提示", "暂未支持");
    }
  }
}
