import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dm_music_flutter/models/music.dart';
import 'package:dm_music_flutter/pages/home/home_controller.dart';
import 'package:dm_music_flutter/painters/bottom_painter.dart';
import 'package:dm_music_flutter/widgets/app_bar.dart';
import 'package:dm_music_flutter/widgets/blur_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _buildAppTitle(context),
      body: _buildBody(),
      bottomNavigationBar: Obx(
        () => _buildBottomNavigationBar(context),
      ),
    );
  }

  /// App标题
  PreferredSizeWidget _buildAppTitle(BuildContext context) {
    return getAppBar(
        appHeight: 50,
        backgroundColor: Theme.of(context).cardColor,
        radius: const BorderRadius.vertical(
          bottom: Radius.circular(10),
        ),
        title: Text(
          "Music",
          style: TextStyle(
            fontSize: 22,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (Get.isDarkMode) {
                Get.changeThemeMode(ThemeMode.light);
              } else {
                Get.changeThemeMode(ThemeMode.dark);
              }
            },
            icon: SvgPicture.asset(
              "images/change.svg",
              colorFilter: ColorFilter.mode(
                Theme.of(context).appBarTheme.foregroundColor!,
                BlendMode.srcIn,
              ),
            ),
          ),
        ]);
  }

  /// 身体部分
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 20,
          childAspectRatio: 3 / 4,
        ),
        itemCount: controller.musics.length,
        itemBuilder: (BuildContext context, int index) {
          Music music = controller.musics[index];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.playMusic(music);
            },
            child: _buildMusicItem(context, music),
          );
        },
      ),
    );
  }

  /// 绘制底部组件
  Widget _buildBottomNavigationBar(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 10,
            bottom: 0,
            child: SlideInUp(
              animate: controller.playing.value,
              onFinish: (direction) {
                if (direction == AnimateDoDirection.backward) {
                  controller.showMusicInfo.value = false;
                }
              },
              child: controller.showMusicInfo.value
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        BlurWidget(
                          blurRadius: 10,
                          hasTopBorder: true,
                          backgroundColor: Theme.of(context).cardColor,
                          radius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          top: 24,
                          right: 20,
                          child: _buildPlayMusicInfo(context),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: RepaintBoundary(
              child: CustomPaint(
                size: const Size.fromHeight(100),
                painter: BottomPainter(
                  controller.progress,
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).progressIndicatorTheme.color!,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildPlayControl(context),
          ),
        ],
      ),
    );
  }

  /// 歌曲单项
  Widget _buildMusicItem(BuildContext context, Music music) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: music.image,
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BlurWidget(
              radius: const BorderRadius.vertical(
                bottom: Radius.circular(10),
              ),
              hasTopBorder: true,
              backgroundColor: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      music.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      music.auth,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 绘制播放曲目信息
  Widget _buildPlayMusicInfo(BuildContext context) {
    if (controller.currentMusic.value == null) {
      return const SizedBox();
    }
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: controller.currentMusic.value!.image,
            width: 46,
            height: 46,
            fit: BoxFit.fill,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.currentMusic.value!.name,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
            Text(
              controller.currentMusic.value!.auth,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
            ),
          ],
        ),
        const Spacer(),
        SvgPicture.asset(
          "images/heart.svg",
          color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(.5),
        )
      ],
    );
  }

  /// 播放器控制界面
  Widget _buildPlayControl(context) {
    // GestureDetector(
    //           onTap: () async {
    //             await controller.player.stop();
    //             //controller.playing.value = false;
    //             controller.playing.value = false;
    //           },
    //           child: Image.asset(
    //             "images/play.png",
    //             height: 160,
    //           ),
    //         )
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "images/previous.svg",
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          IconButton(
            style: ButtonStyle(
              padding: const WidgetStatePropertyAll(
                EdgeInsets.all(15),
              ),
              backgroundBuilder: (context, states, child) {
                return DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage("images/button_bg.png"),
                    ),
                  ),
                  child: child,
                );
              },
            ),
            onPressed: () async {
              if (controller.playing.value) {
                controller.stop();
              } else {
                controller.play();
              }
            },
            icon: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              size: 30,
              color: const Color.fromARGB(255, 0, 46, 59),
              progress: controller.controller,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset("images/next.svg",
                color: Theme.of(context).textTheme.bodyMedium!.color),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
