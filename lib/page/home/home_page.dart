import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:inspire_blur/inspire_blur.dart';
import 'package:dm_music/page/home/home_logic.dart';
import 'package:dm_music/page/home/play_logic.dart';
import 'package:dm_music/page/home/widget/music_category_item.dart';
import 'package:dm_music/page/home/widget/music_control.dart';
import 'package:dm_music/page/home/widget/music_hot_item.dart';
import 'package:dm_music/page/home/widget/music_play_info_card.dart';
import 'package:dm_music/pages/frame/widgets/bottom_curve_widget.dart';
import 'package:dm_music/widgets/blur_widget.dart';
import 'package:dm_music/widgets/slider.dart';

/// 主页
class HomePage extends StatefulWidget {
  const new({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 是否开启模糊
  bool isBlur = false;

  // 放置主页逻辑
  final homeLogic = Get.put(HomeLogic());

  // 放置播放页逻辑
  final playLogic = Get.put(PlayLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DMusic'),
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings04),
            onPressed: () {
              isBlur = !isBlur;
              setState(() {});
            },
          ),
          SizedBox(width: 5),
        ],
        flexibleSpace: isBlur
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Inspire.backdropBlur(
                    config: InspireBlurConfig.topToBottom(
                      sigma: 60,
                      fadeCurve: Curves.linear,
                    ),
                    child: SizedBox.expand(),
                  ),

                  Inspire.tint.topToBottom(
                    color: Colors.black,
                    opacity: .8,
                    curve: Curves.easeOut,
                  ),
                ],
              )
            : BlurWidget(
                child: SizedBox.expand(),
              ),
      ),
      extendBodyBehindAppBar: true,
      body: buildBody(),
    );
  }

  /// 构建主页
  Widget buildBody() {
    // 控制区域高度
    final double buttonHeight = 100;

    /// 底部安全区域 48
    final double bottomSafeHeight;
    if (Platform.isIOS) {
      bottomSafeHeight = 0;
    } else {
      bottomSafeHeight = MediaQuery.of(context).padding.bottom;
    }

    //弧形区域高度(不包含歌曲信息的区域) 控制区域高度 + 底部安全区域高度
    final double curveHeight = buttonHeight + bottomSafeHeight;

    // 底部容器整体高度
    final double controllerHeight = 84 + buttonHeight + bottomSafeHeight;

    return Stack(
      fit: .expand,
      children: [
        homeLogic.obx(
          (state) => buildList(controllerHeight),
        ),

        // 底部播放区域
        GetBuilder<PlayLogic>(
          builder: (logic) {
            if (logic.currentMusic.value == null) {
              return SizedBox();
            }
            return Stack(
              children: [
                // 最底部的滑动信息卡片
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: controllerHeight,
                  child: SlideInUp(
                    from: 105,
                    animate: logic.slideController?.isCompleted ?? false,
                    controller: (slideController) {
                      logic.slideController = slideController;
                    },
                    child: PlayInfoCard(logic.currentMusic.value!),
                  ),
                ),

                // 黑色蒙版
                Align(
                  alignment: .bottomCenter,
                  child: BottomCurveWidget(
                    size: Size.fromHeight(curveHeight),
                    backgroundColor: Colors.black,
                  ),
                ),

                // 进度条
                Positioned(
                  left: 0,
                  right: 0,
                  height: 35,
                  bottom: bottomSafeHeight + 75,
                  child: Obx(
                    () => DMSlider(
                      bezier: 16,
                      sliderType: .curve,
                      value: playLogic.progress.value,
                      onChangeStart: (value) {
                        playLogic.isDragging = true;
                      },
                      onChanged: (value) {
                        playLogic.progress.value = value;
                      },
                      onChangeEnd: (value) {
                        playLogic.isDragging = false;
                        playLogic.onTapProgress(value);
                      },
                    ),
                  ),
                ),

                // 底部控制按钮
                Positioned(
                  left: 0,
                  right: 0,
                  height: buttonHeight, // 控制区域高度 100
                  bottom: bottomSafeHeight,
                  child: MusicControl(
                    logic.btnController,
                    onPlayPause: logic.playPause,
                    onPrevious: logic.playPrevious,
                    onNext: logic.playNext,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// 构建列表组件
  Widget buildList(double controllerHeight) {
    return CustomScrollView(
      scrollCacheExtent: ScrollCacheExtent.pixels(2000),
      slivers: [
        if (homeLogic.playMusic.isNotEmpty) ...{
          // "最近播放" 标题
          SliverSafeArea(
            bottom: false,
            minimum: EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverToBoxAdapter(
              child: MusicCategoryItem("RECENTLY PLAYED"),
            ),
          ),

          // 测试数据
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                scrollDirection: Axis.horizontal,
                itemCount: homeLogic.playMusic.length,
                itemBuilder: (context, index) {
                  final music = homeLogic.playMusic[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      memCacheWidth: 200,
                      memCacheHeight: 200,
                      imageUrl: music.cover,
                      fit: BoxFit.cover,
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(width: 10);
                },
              ),
            ),
          ),
        },

        // "最近发布" 标题
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverToBoxAdapter(
            child: MusicCategoryItem("NEW RELEASES"),
          ),
        ),

        // 热门音乐
        SliverPadding(
          padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: 10 + controllerHeight,
          ),
          sliver: SliverGrid.builder(
            itemCount: homeLogic.newMusic.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3 / 3.5,
            ),
            itemBuilder: (context, index) {
              final music = homeLogic.newMusic[index];
              return GestureDetector(
                behavior: .opaque,
                onTap: () {
                  playLogic.playMusic(music);
                  homeLogic.onPlay(music);
                },
                child: MusicHotItem(
                  music,
                  isBlur: isBlur,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
