import 'package:dm_music/apis/cloud_music_api/models/cloud_play_list.dart';
import 'package:dm_music/models/music.dart';
import 'package:dm_music/models/play_list.dart';
import 'package:dm_music/pages/home/home_logic.dart';
import 'package:dm_music/pages/home/widgets/home_end_drawer.dart';
import 'package:dm_music/pages/home/widgets/home_music_category.dart';
import 'package:dm_music/pages/home/widgets/music_new_item.dart';
import 'package:dm_music/pages/home/widgets/music_control.dart';
import 'package:dm_music/pages/home/widgets/music_recently_item.dart';
import 'package:dm_music/themes/dimensions.dart';
import 'package:dm_music/widgets/blur_widget.dart';
import 'package:dm_music/widgets/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// 主页
class HomePage extends GetView<HomeLogic> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeLogic());

    /// 主题
    ThemeData theme = Theme.of(context);

    /// 底部安全区域 48
    final double bottomSafeHeight = MediaQuery.of(context).padding.bottom;

    /// 底部容器总高度
    final double barHeight = 180;

    // 底部容器整体高度 180 + 48
    final double barSafeHeight = 180 + bottomSafeHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DMUSIC'),
        centerTitle: false,
        actions: [
          ThemeButton(),
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                icon: SvgPicture.asset(
                  "assets/svgs/menus.svg",
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
              );
            },
          ),
          10.horizontalSpace,
        ],
        flexibleSpace: BlurWidget(
          child: SizedBox.expand(),
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      endDrawer: HomeEndDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          controller.obx(
            (state) => _buildBody(barSafeHeight),
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

  Widget _buildBody(double bottomHeight) {
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
                  child: Column(
                    spacing: 10,
                    children: [
                      HomeMusicCategory(
                        "本地音乐",
                        "1000首·98次播放",
                        "http://music.dmskin.com/music/Neon Tears.jpg",
                      ),
                      HomeMusicCategory(
                        "Navidrome",
                        "5个播放源",
                        "assets/images/navidrome.png",
                      ),
                    ],
                  ),
                ),
              ),

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
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 3 / 3.5,
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
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 3 / 3.5,
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
