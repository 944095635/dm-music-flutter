import 'package:animate_do/animate_do.dart';
import 'package:dm_music/pages/home/control/music_control_logic.dart';
import 'package:dm_music/pages/home/widgets/bottom_curve_widget.dart';
import 'package:dm_music/pages/home/widgets/music_buttons.dart';
import 'package:dm_music/pages/home/widgets/music_info_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 音乐控制组件
class MusicControl extends GetView<MusicControlLogic> {
  const MusicControl({
    super.key,
    required this.height,
    required this.backgroundColor,
  });

  final double height;

  /// 背景色
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    Get.put(MusicControlLogic());

    /// 底部安全区域
    double bottomSafe = MediaQuery.of(context).padding.bottom;

    /// 底部蒙版高度
    final double bottomBarHeight = 100 + bottomSafe;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        /// 音乐信息
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: height,
          child: SlideInUp(
            from: bottomBarHeight,
            animate: controller.slideController?.isCompleted ?? false,
            controller: (slideController) {
              controller.slideController = slideController;
            },
            child: Obx(
              () => MusicInfoCard(controller.music.value),
            ),
          ),
        ),

        /// 底部黑色蒙版
        BottomCurveWidget(
          size: Size.fromHeight(bottomBarHeight),
          backgroundColor: backgroundColor,
        ),

        /// 音乐按钮
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: bottomBarHeight,
          child: MusicButtons(
            controller: controller.playButtonController,
            onTapPlay: controller.onTapPlay,
          ),
        ),
      ],
    );
  }
}
