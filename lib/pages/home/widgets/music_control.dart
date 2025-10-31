import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dm_music/models/music.dart';
import 'package:dm_music/pages/play/play_logic.dart';
import 'package:dm_music/pages/home/widgets/bottom_curve_widget.dart';
import 'package:dm_music/pages/home/widgets/music_buttons.dart';
import 'package:dm_music/utils/platform_utils.dart';
import 'package:dm_music/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

/// 音乐控制组件
class MusicControl extends GetView<PlayLogic> {
  const MusicControl({
    super.key,
    required this.onTapMusic,
    required this.barHeight,
    required this.curveHeight,
    required this.sliderHeight,
  });

  final double barHeight;

  final double curveHeight;

  final double sliderHeight;

  final VoidCallback onTapMusic;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
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
              child: _buildCard(theme),
            ),
          ),

          /// 底部黑色蒙版
          BottomCurveWidget(
            size: Size.fromHeight(curveHeight),
            backgroundColor: theme.scaffoldBackgroundColor,
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
              () => _buildSlider(),
            ),
          ),
        ],
      ),
    );
  }

  /// 进度条
  Widget _buildSlider() {
    if (controller.music.value == null) {
      return SizedBox.shrink();
    }
    return DMSlider(
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
    );
  }

  /// 搜索卡片区域
  Widget _buildCard(ThemeData theme) {
    BorderRadius topBorderRadius = BorderRadius.vertical(
      top: Radius.circular(20),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: topBorderRadius,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            //color: const Color.fromARGB(255, 255, 0, 0),
            //color: const Color.fromRGBO(60, 60, 60, 0.8),
            color: theme.colorScheme.onSurface.withAlpha(30),
            //color: Colors.red,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 15,
            sigmaY: 15,
          ),
          child: Container(
            padding: const EdgeInsets.only(
              top: 24,
              left: 20,
              right: 20,
            ),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              borderRadius: topBorderRadius,
              border: Border(
                top: const BorderSide(
                  color: Color.fromRGBO(255, 255, 255, 0.65),
                ),
              ),
              color: theme.bottomSheetTheme.modalBackgroundColor,
            ),
            child: GestureDetector(
              onTap: onTapMusic,
              behavior: HitTestBehavior.opaque,
              child: Obx(
                () => _buildInfo(theme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 歌曲信息 头像 + 名称 歌手 + 红心 监听刷新
  Widget _buildInfo(ThemeData theme) {
    Music? music = controller.music.value;
    if (music == null) {
      return SizedBox.shrink();
    }
    return Row(
      spacing: 15,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: music.cover,
            width: 45,
            height: 45,
            fit: BoxFit.fill,
            memCacheHeight: 150,
            memCacheWidth: 150,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  music.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  music.author ?? "",
                  style: theme.textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withAlpha(160),
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            // showModalBottomSheet(
            //   context: Get.context!,
            //   builder: (context) => const PlayListPage(),
            // );
            // controller.music.value!.like.value =
            //     !controller.music.value!.like.value;
            // static const heartBoldSvg = 'assets/svgs/heart_bold.svg';
            // static const heartLineSvg = 'assets/svgs/heart_line.svg';
            music.like.value = !music.like.value;
          },
          icon: SvgPicture.asset(
            music.like.value
                ? 'assets/svgs/heart_bold.svg'
                : 'assets/svgs/heart_line.svg',
            colorFilter: ColorFilter.mode(
              music.like.value
                  ? Colors.red
                  : theme.colorScheme.onSurface.withAlpha(120),
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}
