import 'package:dm_music/helpers/cache_helper.dart';
import 'package:dm_music/pages/home/home_dmusic_page.dart';
import 'package:dm_music/pages/home/navidrome/home_navidrome_page.dart';
import 'package:dm_music/values/strings.dart';
import 'package:dm_music/widgets/sliver_bottom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:dm_music/models/music_source.dart';
import 'package:dm_music/pages/frame/frame_logic.dart';
import 'package:dm_music/pages/frame/widgets/drawer_item.dart';
import 'package:dm_music/pages/frame/widgets/music_control.dart';
import 'package:dm_music/themes/dimensions.dart';
import 'package:dm_music/widgets/blur_widget.dart';
import 'package:dm_music/widgets/theme_button.dart';

/// 主页
class FramePage extends GetView<FrameLogic> {
  const FramePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FrameLogic());

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
        title: const Text(Strings.appName),
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
      endDrawer: GetBuilder<FrameLogic>(
        builder: (controller) {
          return _buildDrawer();
        },
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildNavigator(),

          /// 底部音乐控制组件
          Align(
            alignment: Alignment.bottomCenter,
            child: MusicControl(
              barHeight: barHeight,
              barSafeHeight: barSafeHeight,
              bottomSafeHeight: bottomSafeHeight,
            ),
          ),
        ],
      ),
    );
  }

  /// 局部导航
  Widget _buildNavigator() {
    String route = Get.arguments["route"];
    return Navigator(
      key: Get.nestedKey(1),
      initialRoute: route,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/dmusic":
            return GetPageRoute(
              settings: settings,
              transition: Transition.fadeIn,
              page: () => HomeDmusicPage(),
            );
          case "/navidrome":
            return GetPageRoute(
              settings: settings,
              transition: Transition.fadeIn,
              page: () => HomeNavidromePage(),
            );
          default:
            return GetPageRoute(
              settings: settings,
              transition: Transition.fadeIn,
              page: () => SizedBox(),
            );
        }
      },
    );
  }

  /// 右滑菜单
  Widget _buildDrawer() {
    return BlurWidget(
      radius: BorderRadius.circular(15),
      child: Drawer(
        child: CustomScrollView(
          slivers: [
            SliverSafeArea(
              bottom: false,
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        MusicSourceType.dmusic.icon,
                        width: 48,
                        height: 48,
                      ),
                      10.verticalSpace,
                      Text(
                        Strings.appName,
                      ),
                      Text(
                        "v2.0.7",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(Dimensions.pagePadding),
              sliver: SliverList.separated(
                itemCount: controller.sourceList.length,
                itemBuilder: (context, index) {
                  MusicSource source = controller.sourceList[index];
                  return DrawerItem(
                    source.type.name,
                    source.type.icon,
                    controller.sourceId == source.id,
                    tag: source.id,
                    onTap: () {
                      controller.changeSource(source);
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return 10.verticalSpace;
                },
              ),
            ),

            SliverBottomWidget.button(
              "清除所有数据",
              onPressed: () {
                CacheHelper.setSourceId("");
              },
            ),
          ],
        ),
      ),
    );
  }
}
