import 'dart:io';

import 'package:dm_music/models/music.dart';
import 'package:dm_music/pages/home/home_logic.dart';
import 'package:dm_music/pages/home/widgets/music_card.dart';
import 'package:dm_music/pages/home/control/music_control.dart';
import 'package:dm_music/widgets/blur_widget.dart';
import 'package:dm_music/widgets/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:flutter_svg/svg.dart';
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

    // 底部容器整体高度
    double barHeight = 180 + bottomSafe;

    /// 底部蒙版高度
    final double curveHeight = 100 + bottomSafe;

    /// 进度条高度
    final double sliderHeight = 75 + bottomSafe;

    bool isPC = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DMusic'),
        centerTitle: false,
        actions: isPC
            ? null
            : [
                ThemeButton(),
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
                maxWidth: Platform.isAndroid || Platform.isIOS
                    ? double.infinity
                    : 500,
              ),
              child: MusicControl(
                barHeight: barHeight,
                curveHeight: curveHeight,
                sliderHeight: sliderHeight,
                backgroundColor: theme.scaffoldBackgroundColor,
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
            bottom: bottomHeight,
          ),
          sliver: SliverPadding(
            padding: const EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              bottom: 15,
            ),
            sliver: SliverGrid.builder(
              itemCount: list.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isPC ? 4 : 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: isPC ? 1 / 1.2 : 3 / 3.8,
              ),
              itemBuilder: (context, index) {
                Music music = list[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    controller.onTapMusic(music);
                  },
                  child: MusicCard(music),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
