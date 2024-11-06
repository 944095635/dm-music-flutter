import 'package:cached_network_image/cached_network_image.dart';
import 'package:dm_music/extension/duration_extensions.dart';
import 'package:dm_music/extension/svg_picture_extensions.dart';
import 'package:dm_music/pages/play/widgets/play_control.dart';
import 'package:dm_music/pages/play_list/index.dart';
import 'package:dm_music/values/svgs.dart';
import 'package:dm_music/widgets/slider/slider.dart' as dmslider;
import 'package:dm_music/widgets/slider/slider_theme.dart' as dm_slider_theme;
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:get/get.dart';
import 'index.dart';

class PlayPage extends GetView<PlayController> {
  const PlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("重绘Play播放页面");
    Get.lazyPut(() => PlayController());
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        // systemOverlayStyle: theme.appBarTheme.systemOverlayStyle!.copyWith(
        //   systemNavigationBarColor: theme.colorScheme.inverseSurface,
        // ),
        actions: [
          IconButton(
            onPressed: () {
              if (Get.isDarkMode) {
                Get.changeThemeMode(ThemeMode.light);
              } else {
                Get.changeThemeMode(ThemeMode.dark);
              }
            },
            icon: SvgPictureExtensions.asset(
                AssetsSvgs.musicRepeatSvg, Colors.white),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    debugPrint("重绘Play播放页面Body");
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Obx(
            () => controller.music.value != null
                ? CachedNetworkImage(
                    imageUrl: controller.music.value!.cover,
                    fit: BoxFit.cover,
                  )
                : const SizedBox(),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  theme.colorScheme.surface.withOpacity(.3),
                  theme.colorScheme.surface,
                ],
              ),
            ),
          ),
          Positioned(
            left: 30,
            right: 30,
            bottom: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(
                  () => _buildMusicTitle(theme),
                ),
                20.verticalSpace,
                PlayControl(
                  controller: controller.playController,
                  onTapPlay: controller.onTapPlay,
                  onTapPrevious: controller.onTapPrevious,
                  onTapNext: controller.onTapNext,
                  onTapPlayList: () {
                    showModalBottomSheet(
                      context: Get.context!,
                      builder: (context) => const PlayListPage(),
                    );
                  },
                ),
                20.verticalSpace,
                SizedBox(
                  height: 30,
                  child: Obx(
                    () => dmslider.Slider(
                      value: controller.progress.value,
                      thumbColor: Colors.white,
                      trackShape:
                          const dm_slider_theme.RoundedRectSliderTrackShape(),
                      onChangeStart: (value) {
                        controller.dragProgress = true;
                      },
                      onChanged: (value) {
                        controller.progress.value = value;
                      },
                      onChangeEnd: (value) {
                        controller.dragProgress = false;
                        controller.onTapProgress(value);
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => _buildMusicTimePosition(theme)),
                    Obx(() => _buildMusicTimeDuration(theme)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 歌曲标题
  Widget _buildMusicTitle(ThemeData theme) {
    debugPrint("重绘Play播放页面 歌曲标题");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.music.value?.name ?? "",
          style: theme.textTheme.bodyLarge!.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        4.verticalSpace,
        Text(
          controller.music.value?.author ?? "",
          style: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(.8),
          ),
        ),
        10.verticalSpace,
        Text(
          controller.lyric,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(.6),
          ),
        ),
      ],
    );
  }

  /// 歌曲时间信息
  Widget _buildMusicTimePosition(ThemeData theme) {
    debugPrint("重绘Play播放页面 时间Position");
    return Text(
      controller.position.value.format(),
      style: theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(.6),
      ),
    );
  }

  /// 歌曲总时间信息
  Widget _buildMusicTimeDuration(ThemeData theme) {
    debugPrint("重绘Play播放页面 时间Duration");
    return Text(
      controller.duration.value.format(),
      style: theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(.6),
      ),
    );
  }
}
