import 'package:dm_music/models/music.dart';
import 'package:dm_music/pages/home/home_logic.dart';
import 'package:dm_music/pages/home/widgets/music_new_item.dart';
import 'package:dm_music/pages/home/widgets/music_control.dart';
import 'package:dm_music/pages/home/widgets/music_recently_item.dart';
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

    /// 主题
    // ThemeData theme = Theme.of(context);

    /// 底部安全区域
    double bottomSafe = MediaQuery.of(context).padding.bottom;

    // 底部容器整体高度
    double barHeight = 180 + bottomSafe;

    /// 底部蒙版高度
    final double curveHeight = 100 + bottomSafe;

    /// 进度条高度
    final double sliderHeight = 75 + bottomSafe;

    /// 是否PC端
    bool isPC = PlatformUtils.isDesktop;

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
            (state) => _buildBody(state!, isPC, barHeight),
          ),

          /// 底部音乐控制组件
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isPC ? 500 : double.infinity,
              ),
              child: MusicControl(
                barHeight: barHeight,
                curveHeight: curveHeight,
                sliderHeight: sliderHeight,
                onTapMusic: controller.onTapPlay,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<Music> list, bool isPC, double bottomHeight) {
    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          minimum: EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: bottomHeight + 20,
          ),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "RECENTLY PLAYED",
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
                    itemCount: controller.recentlyPlayed.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      Music music = controller.recentlyPlayed[index];
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

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "NEW RELEASES",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SliverGrid.builder(
                itemCount: list.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isPC ? 4 : 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: isPC ? 1 / 1.2 : 3 / 3.5,
                ),
                itemBuilder: (context, index) {
                  Music music = list[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      controller.onTapMusic(index);
                    },
                    child: MusicNewItem(music),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
