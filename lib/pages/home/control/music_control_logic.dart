import 'package:dm_music/models/music.dart';
import 'package:dm_music/services/play_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MusicControlLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// 播放服务
  final PlayService playService = Get.find();

  /// 当前播放音乐
  final Rxn<Music> music = Rxn<Music>();

  /// 是否显示控制组件
  AnimationController? slideController;

  /// 播放按钮动画控制器
  late AnimationController playButtonController;

  @override
  void onClose() {
    slideController?.dispose();
    playButtonController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    playButtonController = AnimationController(vsync: this)
      ..duration = Durations.long2;

    playService.listenMusicEvent((newMusic) {
      music.value = newMusic;
    });

    playService.listenPlayerState((state) {
      if (state.playing) {
        playButtonController.forward();
        slideController?.forward();
      } else {
        playButtonController.reverse();
        slideController?.reverse();
      }
    });
  }

  /// 点击播放按钮
  void onTapPlay() {
    playService.playOrPause();
  }
}
