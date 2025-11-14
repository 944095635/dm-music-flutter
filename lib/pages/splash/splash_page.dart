import 'package:dm_music/pages/home/home_page.dart';
import 'package:dm_music/pages/init/init_page.dart';
import 'package:dm_music/pages/play/play_logic.dart';
import 'package:dm_music/services/app_service.dart';
import 'package:dm_music/services/play_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 启动屏
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    // 放置服务
    AppService appService = Get.put(AppService());
    // 放置服务
    Get.put(PlayService());
    // 放置播放控制器
    Get.lazyPut(() => PlayLogic());
    await appService.init();
    Get.offAll(() => InitPage());
    return;
    if (appService.isInit) {
      await Future.delayed(Durations.extralong4);
      Get.offAll(() => HomePage());
    } else {
      Get.offAll(() => InitPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Center(
        child: Image.asset(
          "assets/images/logo.png",
          width: 200,
          cacheWidth: 400,
        ),
      ),
    );
  }
}
