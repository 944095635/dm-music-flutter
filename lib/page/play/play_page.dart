import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:dm_music/page/home/widget/music_control.dart';
import 'package:dm_music/page/play/play_logic.dart';
import 'package:dm_music/service/play_service.dart';
import 'package:dm_music/value/http_keys.dart';
import 'package:dm_music/widget/slider.dart';

/// 播放页
class PlayPage extends GetView<PlayLogic> {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: GetBuilder<PlayLogic>(
        builder: (controller) {
          return buildBody();
        },
      ),
    );
  }

  /// 构建播放页主体
  Widget buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double imageSize = constraints.maxWidth * .65;
        return Stack(
          fit: StackFit.expand,
          children: [
            // 模糊背景层
            if (controller.currentMusic.value != null) ...{
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: constraints.maxHeight * .8,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: controller.currentMusic.value!.cover,
                    width: imageSize,
                    height: imageSize,
                    memCacheHeight: 20,
                    memCacheWidth: 20,
                    fit: BoxFit.fill,
                    httpHeaders: HttpKeys.headers,
                  ),
                ),
              ),

              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 150,
                    sigmaY: 150,
                  ),
                  child: SizedBox.expand(),
                ),
              ),
            },

            // 封面
            Column(
              children: [
                Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    memCacheWidth: 600,
                    imageUrl: controller.currentMusic.value!.cover,
                    httpHeaders: HttpKeys.headers,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 120,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: _buildMusicTitle(),
                        ),
                        SizedBox(height: 10),
                        Obx(
                          () => DMSlider(
                            value: controller.progress.value,
                            onChangeStart: (value) {
                              controller.isDragging = true;
                            },
                            onChanged: (value) {
                              controller.progress.value = value;
                            },
                            onChangeEnd: (value) {
                              controller.isDragging = false;
                              controller.onTapProgress(value);
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        MusicControl(
                          controller.btnController,
                          onPlayPause: PlayService.playOrPause,
                          onPrevious: PlayService.playPrevious,
                          onNext: PlayService.playNext,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// 歌曲标题
  Widget _buildMusicTitle() {
    //debugPrint("_buildMusicTitle");
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.currentMusic.value!.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: .bold,
                ),
              ),
              Text(
                controller.currentMusic.value!.author,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Text("词"),
        ),
      ],
    );
  }
}
