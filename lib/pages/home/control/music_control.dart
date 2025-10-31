import 'package:animate_do/animate_do.dart';
import 'package:dm_music/pages/home/control/music_control_logic.dart';
import 'package:dm_music/pages/home/widgets/bottom_curve_widget.dart';
import 'package:dm_music/pages/home/widgets/music_buttons.dart';
import 'package:dm_music/pages/home/widgets/music_info_card.dart';
import 'package:dm_music/utils/platform_utils.dart';
import 'package:dm_music/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 音乐控制组件
class MusicControl extends GetView<MusicControlLogic> {
  const MusicControl({
    super.key,
    required this.barHeight,
    required this.curveHeight,
    required this.sliderHeight,
    required this.backgroundColor,
  });

  final double barHeight;

  final double curveHeight;

  final double sliderHeight;

  /// 背景色
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    Get.put(MusicControlLogic());
    return SizedBox(
      height: barHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          /// 音乐信息
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight,
            child: SlideInUp(
              from: PlatformUtils.isDesktop ? curveHeight + 20 : curveHeight,
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
            size: Size.fromHeight(curveHeight),
            backgroundColor: backgroundColor,
          ),

          /// 音乐按钮
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: curveHeight,
            child: MusicButtons(
              controller: controller.playButtonController,
              onTapPlay: controller.onTapPlay,
              onTapNext: controller.onTapNext,
              onTapPrevious: controller.onTapPrevious,
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            height: 36,
            bottom: sliderHeight,
            child: Obx(
              () => controller.music.value != null
                  ? DMSlider(
                      bezier: 16,
                      sliderType: SliderType.curve,
                      value: controller.progress.value,
                      onChangeStart: (value) {
                        controller.isDragProgress = true;
                      },
                      onChanged: (value) {
                        controller.progress.value = value;
                      },
                      onChangeEnd: (value) {
                        controller.isDragProgress = false;
                        controller.onTapProgress(value);
                      },
                    )
                  : SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
