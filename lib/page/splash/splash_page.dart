import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:dm_music/helpers/network_helper.dart';
import 'package:dm_music/page/home/home_page.dart';

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

  /// 初始化
  void init() async {
    // 初始化音频解码
    MediaKit.ensureInitialized();

    await Future.delayed(Duration(seconds: 1));

    // iOS 专用网络初始化（解决首次安装无网络问题）
    if (Platform.isIOS) {
      await _initIOSNetwork();
    }

    /// 跳至首页
    Get.offAll(() => HomePage(), transition: .fadeIn);
  }

  /// iOS 网络初始化（循环调用 NetworkHelper.init() 直到成功）
  Future<void> _initIOSNetwork() async {
    const int maxRetries = 30;
    const Duration retryDelay = Duration(seconds: 5);

    for (int i = 0; i < maxRetries; i++) {
      try {
        await NetworkHelper.init();
        debugPrint("iOS 网络初始化成功（第 ${i + 1} 次尝试）");
        return;
      } catch (e) {
        debugPrint("iOS 网络初始化第 ${i + 1} 次尝试失败: $e");
      }

      if (i < maxRetries - 1) {
        await Future.delayed(retryDelay);
      }
    }

    debugPrint("iOS 网络初始化达到最大重试次数");
  }
}
