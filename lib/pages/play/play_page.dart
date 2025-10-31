import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dm_music/extension/duration_extensions.dart';
import 'package:dm_music/pages/play/play_buttons.dart';
import 'package:dm_music/pages/play/play_logic.dart';
import 'package:dm_music/widgets/slider.dart';
import 'package:dm_music/widgets/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:get/get.dart';

class PlayPage extends GetView<PlayLogic> {
  const PlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("重绘Play播放页面");
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: theme.colorScheme.onSurface,
        systemOverlayStyle: theme.appBarTheme.systemOverlayStyle!.copyWith(
          //systemNavigationBarColor: theme.colorScheme.inverseSurface,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: [
          ThemeButton(false),
          10.horizontalSpace,
        ],
      ),
      extendBodyBehindAppBar: true,
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    debugPrint("重绘Play播放页面Body");

    /// 时间文字颜色
    Color textColor = theme.colorScheme.onSurface.withAlpha(160);

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// 刷新监听 - 背景图
          Obx(
            () => _buildBackImage(),
          ),

          if (Get.isDarkMode) ...{
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black54,
              ),
            ),
          },

          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 140,
                sigmaY: 140,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.bottomSheetTheme.modalBackgroundColor,
                ),
              ),
            ),
          ),

          Positioned(
            top: 120,
            bottom: 80,
            left: 20,
            right: 20,
            child: Column(
              children: [
                /// 头像区域
                Expanded(
                  child: Center(
                    child: Obx(
                      () => ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          memCacheWidth: 360,
                          imageUrl: controller.music.value!.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                /// 底部信息区域
                Column(
                  spacing: 40,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Obx(
                        () => _buildMusicTitle(theme),
                      ),
                    ),

                    PlayButtons(
                      controller: controller.playButtonController,
                      onTapPlay: controller.onTapPlay,
                      onTapNext: controller.onTapNext,
                      onTapPrevious: controller.onTapPrevious,
                      //   onTapPlayList: () async {
                      //     // await showModalBottomSheet(
                      //     //   context: Get.context!,
                      //     //   builder: (context) => const PlayListPage(),
                      //     // );
                      //     // Get.delete<PlayListController>();
                      //   },
                    ),
                    Obx(
                      () => _buildPlayInfo(textColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 背景图
  Widget _buildBackImage() {
    return controller.music.value != null
        ? CachedNetworkImage(
            imageUrl: controller.music.value!.cover,
            fit: BoxFit.cover,
          )
        : const SizedBox.shrink();
  }

  /// 进度条
  Widget _buildSlider() {
    //debugPrint("_buildSlider");
    return DMSlider(
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

  /// 歌曲标题
  Widget _buildMusicTitle(ThemeData theme) {
    //debugPrint("_buildMusicTitle");
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.music.value?.name ?? "",
          style: theme.textTheme.bodyLarge,
        ),
        Text(
          controller.music.value?.author ?? "",
          style: theme.textTheme.bodyMedium,
        ),
        // 10.verticalSpace,
        // Text(
        //   "controller.lyric",
        //   style: theme.textTheme.bodyMedium!.copyWith(
        //     color: theme.colorScheme.onSurface.withAlpha(180),
        //   ),
        // ),
      ],
    );
  }

  /// 播放信息 - 播放时高强度重绘
  Widget _buildPlayInfo(Color textColor) {
    //debugPrint("_buildPlayInfo");
    return Column(
      spacing: 5,
      children: [
        _buildSlider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.position.value.format(),
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
              Text(
                controller.duration.value.format(),
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
