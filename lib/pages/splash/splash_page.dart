import 'package:dm_music/pages/frame/frame_page.dart';
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
    await Future.delayed(Durations.long4);
    Get.offAll(() => FramePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FlutterLogo(),
    );
  }
}
