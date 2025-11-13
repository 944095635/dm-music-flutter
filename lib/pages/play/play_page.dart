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
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        // foregroundColor: theme.colorScheme.onSurface,
        // systemOverlayStyle: theme.appBarTheme.systemOverlayStyle!.copyWith(
        //   //systemNavigationBarColor: theme.colorScheme.inverseSurface,
        //   statusBarIconBrightness: Brightness.light,
        // ),
        actions: [
          ThemeButton(),
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
    final Color textColor = theme.colorScheme.onSurface.withAlpha(160);

    return LayoutBuilder(
      builder: (context, constraints) {
        double imageSize = constraints.maxWidth * .65;
        return SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// 刷新监听 - 背景图
              // Obx(
              //   () => _buildBackImage(),
              // ),

              // if (Get.isDarkMode) ...{
              //   DecoratedBox(
              //     decoration: BoxDecoration(
              //       color: Colors.black54,
              //     ),
              //   ),
              // },
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: constraints.maxHeight * .75,
                child: Center(
                  child: Obx(
                    () => CachedNetworkImage(
                      imageUrl: controller.music.value!.cover,
                      width: imageSize,
                      height: imageSize,
                      memCacheHeight: 20,
                      memCacheWidth: 20,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),

              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 150,
                    sigmaY: 150,
                  ),
                  child: SizedBox.expand(),
                ),
              ),

              Positioned(
                left: 20,
                right: 20,
                top: 80,
                bottom: 80,
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Obx(
                          () => ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              memCacheWidth: 600,
                              imageUrl: controller.music.value!.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// 底部信息区域
                    Column(
                      spacing: 24,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Obx(
                            () => _buildMusicTitle(theme),
                          ),
                        ),

                        PlayButtons(
                          onTapPlay: controller.onTapPlay,
                          onTapNext: controller.onTapNext,
                          onTapPrevious: controller.onTapPrevious,
                          controller: controller.playButtonController,
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
      },
    );
  }

  /// 背景图
  // Widget _buildBackImage() {
  //   return controller.music.value != null
  //       ? CachedNetworkImage(
  //           imageUrl: controller.music.value!.cover,
  //           fit: BoxFit.cover,
  //         )
  //       : const SizedBox.shrink();
  // }

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
      spacing: 5,
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
