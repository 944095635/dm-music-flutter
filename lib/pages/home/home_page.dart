import 'package:animate_do/animate_do.dart';
import 'package:dm_music/models/music.dart';
import 'package:dm_music/pages/home/home_logic.dart';
import 'package:dm_music/pages/home/widgets/bottom_curve_widget.dart';
import 'package:dm_music/pages/home/widgets/music_card.dart';
import 'package:dm_music/pages/home/widgets/music_control.dart';
import 'package:dm_music/pages/home/widgets/music_info_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 主页
class HomePage extends GetView<HomeLogic> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeLogic());

    /// 主题
    ThemeData theme = Theme.of(context);

    /// 底部安全区域
    double bottomSafe = MediaQuery.of(context).padding.bottom;

    /// 底部蒙版高度
    final double bottomBarHeight = 100 + bottomSafe;

    // 底部容器整体高度
    double bottomHeight = 180 + bottomSafe;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          controller.obx(
            (state) => _buildBody(state!, bottomHeight),
          ),

          /// 音乐信息
          Align(
            alignment: Alignment.bottomCenter,
            child: Obx(
              () => SlideInUp(
                from: bottomBarHeight,
                animate: controller.showBar.value,
                child: SizedBox(
                  height: bottomHeight,
                  child: MusicInfoCard(controller.music.value),
                ),
              ),
            ),
          ),

          /// 底部黑色蒙版
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomCurveWidget(
              size: Size.fromHeight(bottomBarHeight),
              backgroundColor: theme.scaffoldBackgroundColor.withAlpha(50),
              child: MusicControl(
                controller: controller.playButtonController,
                onTapPlay: controller.onTapPlayButton,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<Music> list, double bottomHeight) {
    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          minimum: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: bottomHeight + 20,
          ),
          sliver: SliverGrid.builder(
            itemCount: list.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3 / 3.8,
            ),
            itemBuilder: (context, index) {
              Music music = list[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  controller.music.value = music;
                },
                child: MusicCard(music),
              );
            },
          ),
        ),
      ],
    );
  }
}
