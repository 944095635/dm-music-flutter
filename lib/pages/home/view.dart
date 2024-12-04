import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dm_music/api/cloud_music_api/models/cloud_play_list.dart';
import 'package:dm_music/extension/svg_picture_extensions.dart';
import 'package:dm_music/index.dart';
import 'package:dm_music/models/music.dart';
import 'package:dm_music/pages/home/widgets/bottom_curve_widget.dart';
import 'package:dm_music/pages/home/widgets/play_mini_control.dart';
import 'package:dm_music/widgets/blur_widget.dart';
import 'package:dm_music/widgets/heart_widget.dart';
import 'package:dm_music/widgets/highlight_widget.dart';
import 'package:dm_music/widgets/shadow_widget.dart';
import 'package:dm_music/widgets/slider/slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/radius_extension.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:get/get.dart';

import 'index.dart';

/// 首页
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("重绘Home主页面");

    Get.lazyPut(() => HomeController());

    ThemeData theme = Theme.of(context);
    BorderRadius borderRadius = BorderRadius.vertical(
      top: 20.radius,
    );

    /// 底部安全区域
    double bottom = MediaQuery.of(context).padding.bottom;

    // 底部容器整体高度
    double bottomHeight = 180 + bottom;

    return Scaffold(
      key: controller.scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: SizedBox.expand(
          child: BlurWidget(
            child: HighlightWidget(
              backgroundColor: theme.bottomSheetTheme.modalBackgroundColor,
              child: AppBar(
                title: Text(
                  "Music",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      controller.openDrawer();
                    },
                    icon: SvgPictureExtensions.asset(
                      AssetsSvgs.userBoldSvg,
                      theme.colorScheme.onSurface,
                    ),
                  ),
                  10.horizontalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
      // appBar: AppBar(

      // ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      endDrawer: BlurWidget(
        child: Drawer(
          child: _buildDrawer(theme),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          controller.obx(
            (data) => _buildBody(theme, data),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Obx(
              () => SlideInUp(
                from: bottomHeight + bottom,
                animate: controller.displayMusicInfo.value,
                child: SizedBox(
                  height: bottomHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 模糊背景层
                      ShadowWidget(
                        borderRadius: borderRadius,
                        child: BlurWidget(
                          borderRadius: borderRadius,
                          child: HighlightWidget(
                            hasTopBorder: true,
                            borderRadius: borderRadius,
                            backgroundColor:
                                theme.bottomSheetTheme.modalBackgroundColor,
                          ),
                        ),
                      ),
                      // 音乐信息
                      Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: controller.onTapPlayMusic,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              top: 24,
                              right: 20,
                            ),
                            child: _buildPlayMusic(theme),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 底部蒙版
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomCurveWidget(
              size: Size.fromHeight(100 + bottom),
              backgroundColor: theme.scaffoldBackgroundColor,
            ),
          ),

          // 底部进度条
          // Positioned(
          //   bottom: 75,
          //   left: 0,
          //   right: 0,
          //   child: CurveProgressIndicator(
          //     size: const Size.fromHeight(25),
          //     progress: controller.progress,
          //     onChanged: controller.onTapProgress,
          //   ),
          // ),

          Positioned(
            bottom: 75 + bottom,
            left: 0,
            right: 0,
            child: Obx(
              () => SizedBox(
                height: 25,
                child: DMSlider(
                  sliderType: SliderType.curve,
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
          ),

          // 控制组件
          Positioned(
            left: 0,
            right: 0,
            bottom: bottom,
            child: SizedBox(
              height: 80,
              // 控制条
              child: PlayMiniControl(
                controller: controller.playController,
                onTapPlay: controller.onTapPlay,
                onTapPrevious: controller.onTapPrevious,
                onTapNext: controller.onTapNext,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Drawer 侧边栏
  Widget _buildDrawer(ThemeData theme) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 头像区域
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 30,
              bottom: 30,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: "http://music.dmskin.com/images/user.jpg",
                    width: 46,
                    height: 46,
                    fit: BoxFit.fill,
                    memCacheHeight: 150,
                    memCacheWidth: 150,
                  ),
                ),
                20.horizontalSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dream.Machine",
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      "四川 - 成都",
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(.6),
                      ),
                    ),
                    4.verticalSpace,
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: CupertinoSlidingSegmentedControl(
                    groupValue: Get.isDarkMode,
                    onValueChanged: (value) {
                      if (value == true) {
                        Get.changeThemeMode(ThemeMode.dark);
                      } else {
                        Get.changeThemeMode(ThemeMode.light);
                      }
                    },
                    children: const {
                      false: Text("白昼"),
                      true: Text("夜幕"),
                    },
                  ),

                  // child: Switch(
                  //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  //   value: Get.isDarkMode,
                  //   onChanged: (value) {

                  //   },
                  // ),
                ),
                10.verticalSpace,
                _buildDrawerItem("我的资料", theme),
                _buildDrawerItem("我的收藏", theme),
                _buildDrawerItem("消息", theme),
                _buildDrawerItem("关于", theme),
                _buildDrawerItem("退出", theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Drawer Item
  Widget _buildDrawerItem(
    String title,
    ThemeData theme, {
    Widget? child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          child ??
              SvgPictureExtensions.asset(
                AssetsSvgs.arrowRightSvg,
                theme.colorScheme.onSurface,
                iconSize: 16,
              ),
        ],
      ),
    );
  }

  /// 主体内容
  Widget _buildBody(ThemeData theme, List<Music> data) {
    debugPrint("重绘Home主页面Body");
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // const SliverToBoxAdapter(
        //   child: Padding(
        //     padding: EdgeInsets.only(top: 80),
        //     child: Text("每日推荐"),
        //   ),
        // ),
        SliverToBoxAdapter(
          child: 85.verticalSpace,
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            child: Text(
              "热门歌曲",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 5,
              crossAxisSpacing: 10,
              childAspectRatio: 3 / 3.8,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              Music music = data[index];
              return Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      controller.onTapPlayList(index);
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: music.cover,
                          fit: BoxFit.cover,
                          memCacheHeight: 350,
                          memCacheWidth: 350,
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: BlurWidget(
                            borderRadius: BorderRadius.zero,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color:
                                    theme.bottomSheetTheme.modalBackgroundColor,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      music.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.bodyMedium!.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(.8),
                                      ),
                                    ),
                                    Text(
                                      music.author ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.bodySmall!.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            child: Text(
              "新歌排行榜",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        _buildNewSongs(),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            child: Text(
              "推荐歌单",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        _buildPlayList(),
        SliverToBoxAdapter(
          child: 200.verticalSpace,
        ),
      ],
    );
  }

  /// 正在播放的音乐播放信息
  Widget _buildPlayMusic(ThemeData theme) {
    debugPrint("重绘Home主页面歌曲信息");
    if (controller.music.value == null) {
      return const SizedBox();
    }
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: controller.music.value!.cover,
            width: 46,
            height: 46,
            fit: BoxFit.fill,
            memCacheHeight: 150,
            memCacheWidth: 150,
          ),
        ),
        15.horizontalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.music.value!.name,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              controller.music.value!.author ?? "",
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(.8),
              ),
            ),
            4.verticalSpace,
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            // showModalBottomSheet(
            //   context: Get.context!,
            //   builder: (context) => const PlayListPage(),
            // );
            controller.music.value!.like.value =
                !controller.music.value!.like.value;
          },
          icon: HeartWidget(like: controller.music.value!.like.value),
        )
      ],
    );
  }

  /// 新歌热榜
  Widget _buildNewSongs() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 230,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: controller.newSongs.length,
          itemBuilder: (context, index) {
            Music music = controller.newSongs[index];
            return _buildMusicNewSongItem(context, music);
          },
          separatorBuilder: (BuildContext context, int index) {
            return 10.horizontalSpace;
          },
        ),
      ),
    );
  }

  Widget _buildMusicNewSongItem(BuildContext context, Music music) {
    return AspectRatio(
      aspectRatio: 3 / 3.8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: context.theme.colorScheme.surface,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.onTapPlayNewSong(music);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: music.cover,
                  fit: BoxFit.cover,
                  memCacheHeight: 350,
                  memCacheWidth: 350,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BlurWidget(
                    borderRadius: BorderRadius.zero,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color:
                            context.theme.bottomSheetTheme.modalBackgroundColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              music.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  context.theme.textTheme.bodyMedium!.copyWith(
                                color: context.theme.colorScheme.onSurface
                                    .withOpacity(.8),
                              ),
                            ),
                            Text(
                              music.author ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  context.theme.textTheme.bodySmall!.copyWith(
                                color: context.theme.colorScheme.onSurface
                                    .withOpacity(.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 推荐歌单
  Widget _buildPlayList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      sliver: SliverGrid.builder(
        itemCount: controller.playList.length,
        itemBuilder: (context, index) {
          CloudPlayList music = controller.playList[index];
          return _buildPlayListItem(context, music);
        },
        // ignore: prefer_const_constructors
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 3 / 5,
        ),
      ),
    );
  }

  Widget _buildPlayListItem(BuildContext context, CloudPlayList music) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          controller.onTapPlayListItem(music);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: music.cover,
              fit: BoxFit.cover,
              memCacheHeight: 250,
              memCacheWidth: 250,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BlurWidget(
                borderRadius: BorderRadius.zero,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.theme.bottomSheetTheme.modalBackgroundColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          music.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.theme.textTheme.bodyMedium!.copyWith(
                            fontSize: 12,
                            color: context.theme.colorScheme.onSurface
                                .withOpacity(.8),
                          ),
                        ),
                        Text(
                          "by ${music.author ?? ""}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.theme.textTheme.bodySmall!.copyWith(
                            fontSize: 12,
                            color: context.theme.colorScheme.onSurface
                                .withOpacity(.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
