import 'package:cached_network_image/cached_network_image.dart';
import 'package:dm_music/extension/duration_extensions.dart';
import 'package:dm_music/extension/svg_picture_extensions.dart';
import 'package:dm_music/pages/play/widgets/play_control.dart';
import 'package:dm_music/pages/play_list/index.dart';
import 'package:dm_music/values/svgs.dart';
import 'package:dm_music/widgets/bottom_sheet.dart';
import 'package:dm_music/widgets/slider/slider.dart' as dmslider;
import 'package:flutter/material.dart' hide showModalBottomSheet;
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
        foregroundColor: theme.colorScheme.onSurface,
        systemOverlayStyle: theme.appBarTheme.systemOverlayStyle!.copyWith(
          //systemNavigationBarColor: theme.colorScheme.inverseSurface,
          statusBarIconBrightness: Brightness.light,
        ),
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
              AssetsSvgs.moonBoldSvg,
              theme.colorScheme.onSurface,
            ),
          ),
          10.horizontalSpace,
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
            left: 20,
            right: 20,
            bottom: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Obx(
                    () => _buildMusicTitle(theme),
                  ),
                ),
                20.verticalSpace,
                PlayControl(
                  controller: controller.playController,
                  onTapPlay: controller.onTapPlay,
                  onTapPrevious: controller.onTapPrevious,
                  onTapNext: controller.onTapNext,
                  onTapPlayList: () async {
                   await  showModalBottomSheet(
                      context: Get.context!,
                      builder: (context) => const PlayListPage(),
                    );
                    Get.delete<PlayListController>();
                  },
                ),
                20.verticalSpace,
                SizedBox(
                  height: 40,
                  child: Obx(
                    () => dmslider.DMSlider(
                      value: controller.progress.value,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => _buildMusicTimePosition(theme)),
                      Obx(() => _buildMusicTimeDuration(theme)),
                    ],
                  ),
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
