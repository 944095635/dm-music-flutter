import 'package:dm_music/pages/home/navidrome/home_navidrome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:dm_music/models/music_source.dart';
import 'package:dm_music/pages/frame/frame_logic.dart';
import 'package:dm_music/pages/frame/widgets/drawer_item.dart';
import 'package:dm_music/pages/frame/widgets/music_control.dart';
import 'package:dm_music/pages/home/home_page.dart';
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
              page: () => HomePage(),
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
              sliver: SliverPadding(
                padding: EdgeInsets.all(Dimensions.pagePadding),
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
            ),
          ],
        ),
      ),
    );
  }
}

// SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(Dimensions.pagePadding),
//                   child: Column(
//                     children: [
//                       DrawerItem(
//                         Strings.appName,
//                         "assets/images/logo.png",
//                         true,
//                         tag: "官方播放源 V2.0.7",
//                         onTap: () {
//                           Get.back();
//                           //Get.to(() => LoginPage());
//                           //Get.to(() => InitPage());
//                           Get.toNamed('/dmusic', id: 1);
//                         },
//                       ),
//                       10.verticalSpace,

//                       DrawerItem(
//                         "Navidrome",
//                         "assets/images/navidrome.png",
//                         false,
//                         tag: "测试数据",
//                         onTap: () {
//                           Get.back();
//                           //Get.to(() => LoginPage());
//                           //Get.to(() => InitPage());
//                           Get.toNamed('/navidrome', id: 1);
//                         },
//                       ),
//                       20.verticalSpace,
//                     ],
//                   ),
//                 ),
//               ),
