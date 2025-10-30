import 'package:dm_music/pages/frame/frame_logic.dart';
import 'package:dm_music/pages/home/home_page.dart';
import 'package:dm_music/widgets/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

/// 框架页面
class FramePage extends GetView<FrameLogic> {
  const FramePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FrameLogic());
    return Scaffold(
      body: Stack(
        children: [
          HomePage(),
          DragToMoveArea(
            child: _windowButtons(),
          ),
        ],
      ),
    );
  }

  /// 系统按钮 window button
  Widget _windowButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ThemeButton(true),

        /// 最小化
        IconButton(
          onPressed: () => windowManager.minimize(),
          icon: const Icon(
            Icons.remove,
            size: 16,
          ),
        ),

        /// 最大化/还原
        IconButton(
          onPressed: () async {
            if (await windowManager.isMaximized()) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
          icon: const Icon(
            Icons.crop_square,
            size: 16,
          ),
        ),

        /// 关闭窗口/退出程序
        IconButton(
          onPressed: () => windowManager.close(),
          icon: const Icon(
            Icons.close,
            size: 16,
          ),
        ),
      ],
    );
  }
}
