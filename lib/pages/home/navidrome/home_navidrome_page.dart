import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dm_music/pages/home/navidrome/home_navidrome_logic.dart';
import 'package:dm_music/pages/home/widgets/music_new_item.dart';
import 'package:dm_music/themes/dimensions.dart';

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
              _buildAlbum(theme),

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

  /// 专辑数据
  Widget _buildAlbum(ThemeData theme) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(
              Dimensions.pagePadding,
            ),
            child: Text(
              "Albums",
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.pagePadding,
          ),
          sliver: SliverGrid.builder(
            itemCount: controller.albumList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3 / 3.5,
            ),
            itemBuilder: (context, index) {
              Map album = controller.albumList[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  controller.onTapAlbum(album);
                },
                child: MusicNewItem(
                  music: album["name"],
                  cover: album["cover"],
                  author: album["artist"],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
