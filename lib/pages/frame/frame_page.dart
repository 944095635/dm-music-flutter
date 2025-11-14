import 'package:dm_music/pages/frame/frame_end_drawer.dart';
import 'package:dm_music/pages/home/home_page.dart';
import 'package:dm_music/pages/frame/widgets/music_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:dm_music/widgets/blur_widget.dart';
import 'package:dm_music/widgets/theme_button.dart';

/// 主页
class FramePage extends StatelessWidget {
  const FramePage({super.key});

  @override
  Widget build(BuildContext context) {
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
      endDrawer: FrameEndDrawer(),
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
              page: () => Text("xxxx"),
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
}
