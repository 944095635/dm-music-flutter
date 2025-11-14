import 'package:dm_music/helpers/cache_helper.dart';
import 'package:dm_music/models/music_source.dart';
import 'package:dm_music/pages/frame/frame_page.dart';
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

  /// 初始化
  void init() async {
    // 放置服务
    AppService appService = Get.put(AppService());
    appService.init();
    // 放置服务
    Get.put(PlayService());
    // 放置播放控制器
    Get.lazyPut(() => PlayLogic());

    MusicSource? source = await CacheHelper.getSource();
    if (source != null) {
      /// 跳至首页
      Get.offAll(
        () => FramePage(),
        arguments: {"route": source.type.route},
        transition: Transition.fadeIn,
      );
    } else {
      await Future.delayed(Durations.extralong4);
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
