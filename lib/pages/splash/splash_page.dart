import 'dart:io';

import 'package:dm_music/pages/frame/frame_page.dart';
import 'package:dm_music/pages/home/home_page.dart';
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
    Get.put(PlayService());
    await Future.delayed(Durations.extralong4);
    bool isPC = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    if (isPC) {
      Get.offAll(() => FramePage());
    } else {
      Get.offAll(() => HomePage());
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
