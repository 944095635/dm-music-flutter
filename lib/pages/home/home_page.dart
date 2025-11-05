import 'package:dm_music/apis/cloud_music_api/models/cloud_play_list.dart';
import 'package:dm_music/models/music.dart';
import 'package:dm_music/pages/home/home_logic.dart';
import 'package:dm_music/pages/home/widgets/music_new_item.dart';
import 'package:dm_music/pages/home/widgets/music_control.dart';
import 'package:dm_music/pages/home/widgets/music_recently_item.dart';
import 'package:dm_music/themes/dimensions.dart';
import 'package:dm_music/utils/platform_utils.dart';
import 'package:dm_music/widgets/blur_widget.dart';
import 'package:dm_music/widgets/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:get/get.dart';

/// 主页
class HomePage extends GetView<HomeLogic> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeLogic());

    /// 底部安全区域 48
    final double bottomSafeHeight = MediaQuery.of(context).padding.bottom;

    /// 底部容器总高度
    final double barHeight = 180;

    // 底部容器整体高度 180 + 48
    final double barSafeHeight = 180 + bottomSafeHeight;

    /// 是否PC端
    final bool isPC = PlatformUtils.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DMUSIC'),
        centerTitle: false,
        actions: isPC
            ? null
            : [
                ThemeButton(isPC),
                10.horizontalSpace,
              ],
        flexibleSpace: BlurWidget(
          child: SizedBox.expand(),
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          controller.obx(
            (state) => _buildBody(isPC, barSafeHeight),
          ),

          /// 底部音乐控制组件
          Align(
            alignment: Alignment.bottomCenter,
            child: MusicControl(
              barHeight: barHeight,
              barSafeHeight: barSafeHeight,
              bottomSafeHeight: bottomSafeHeight,
              onTapMusic: controller.onTapPlay,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isPC, double bottomHeight) {
    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          minimum: EdgeInsets.only(
            // left: 15,
            // right: 15,
            bottom: bottomHeight + 20,
          ),
          sliver: SliverMainAxisGroup(
            slivers: [
              if (controller.newReleases.isNotEmpty) ...{
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      Dimensions.pagePadding,
                    ),
                    child: Text(
                      "NEW RELEASES",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.pagePadding,
                      ),
                      itemCount: controller.newReleases.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        Music music = controller.newReleases[index];
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            controller.onTapRecentlyMusic(index);
                          },
                          child: MusicRecentlyItem(music),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return 10.horizontalSpace;
                      },
                    ),
                  ),
                ),
              },

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(
                    Dimensions.pagePadding,
                  ),
                  child: Text(
                    "RECENTLY PLAYED",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.pagePadding,
                ),
                sliver: SliverGrid.builder(
                  itemCount: controller.songs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isPC ? 4 : 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: isPC ? 1 / 1.2 : 3 / 3.5,
                  ),
                  itemBuilder: (context, index) {
                    Music music = controller.songs[index];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        controller.onTapMusic(index);
                      },
                      child: MusicNewItem(
                        music: music.name,
                        cover: music.cover,
                        author: music.author ?? "",
                      ),
                    );
                  },
                ),
              ),

              if (controller.playList.isNotEmpty) ...{
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      Dimensions.pagePadding,
                    ),
                    child: Text(
                      "PLAY LISTED",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.pagePadding,
                  ),
                  sliver: SliverGrid.builder(
                    itemCount: controller.playList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isPC ? 4 : 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: isPC ? 1 / 1.2 : 3 / 3.5,
                    ),
                    itemBuilder: (context, index) {
                      CloudPlayList music = controller.playList[index];
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          controller.onTapPlayListItem(music);
                        },
                        child: MusicNewItem(
                          music: music.name,
                          cover: music.cover,
                          author: music.author ?? "",
                        ),
                      );
                    },
                  ),
                ),
              },
            ],
          ),
        ),
      ],
    );
  }
}
