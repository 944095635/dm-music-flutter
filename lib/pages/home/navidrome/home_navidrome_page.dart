import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dm_music/pages/home/navidrome/home_navidrome_logic.dart';

/// 首页
class HomeNavidromePage extends GetView<HomeNavidromeLogic> {
  const HomeNavidromePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeNavidromeLogic());

    final ThemeData theme = Theme.of(context);

    /// 底部安全区域 48
    final double bottomSafeHeight = MediaQuery.of(context).padding.bottom;

    // 底部容器整体高度 180 + 48
    final double barSafeHeight = 180 + bottomSafeHeight;
    return Scaffold(
      body: controller.obx(
        (state) => _buildBody(theme, barSafeHeight),
      ),
    );
  }

  /// Body
  Widget _buildBody(ThemeData theme, double bottomHeight) {
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
              // _buildDMusic(theme),

              // if (controller.playList.isNotEmpty) ...{
              //   _buildPlayList(theme),
              // },
            ],
          ),
        ),
      ],
    );
  }
}
