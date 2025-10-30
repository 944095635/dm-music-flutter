import 'dart:async';
import 'package:dm_music/models/music.dart';
import 'package:dm_music/services/play_service.dart';
import 'package:dm_music/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MusicControlLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// 播放服务
  final PlayService playService = Get.find();

  /// 当前播放音乐
  final Rxn<Music> music = Rxn<Music>();

  /// 当前进度
  final RxDouble progress = 0.0.obs;

  /// 当前正在拖动进度条
  bool isDragProgress = false;

  /// 当前歌曲播放进度
  //final Rx<Duration> position1 = Rx(Duration.zero);

  /// 当前歌曲长度
  final Rx<Duration> duration = Rx(Duration.zero);

  /// 是否显示控制组件
  AnimationController? slideController;

  /// 播放按钮动画控制器
  late AnimationController playButtonController;

  /// 订阅播放状态
  StreamSubscription? subPlayerState;

  /// 订阅歌曲切换
  StreamSubscription? subMusicChange;

  /// 订阅播放进度
  StreamSubscription? subMusicPosition;

  /// 订阅播放长度
  StreamSubscription? subMusicDuration;

  /// 销毁事件
  @override
  void onClose() {
    //销毁媒体
    music.close();
    //取消订阅
    subPlayerState?.cancel();
    subMusicChange?.cancel();
    subMusicPosition?.cancel();
    subMusicDuration?.cancel();

    //销毁动画控制器
    slideController?.dispose();
    playButtonController.dispose();

    //销毁进度监听
    progress.close();
    //position.close();
    duration.close();

    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    playButtonController = AnimationController(vsync: this)
      ..duration = Durations.long2;

    playService.listenMusicEvent((newMusic) {
      // 桌面平台显示控制组件
      if (PlatformUtils.isDesktop) {
        slideController?.forward();
        playButtonController.forward();
      }
      music.value = newMusic;
    });

    //监听播放状态变化
    subPlayerState = playService.listenPlayerState((state) {
      if (state.playing) {
        slideController?.forward();
        playButtonController.forward();
      } else {
        slideController?.reverse();
        playButtonController.reverse();
        // 暂停的时候 进度等于1，那么重置进度条为0
        if (progress.value == 1) {
          progress.value = 0;
        }
      }
    });

    //监听歌曲变化
    subMusicChange = playService.listenMusicChange((newMusic) {
      /// 更新歌曲
      //music.value = newMusic;
      debugPrint("播放歌曲变化:${newMusic.name}");
    });

    //监听进度变化
    subMusicPosition = playService.listenMusicPosition((
      Duration newPosition,
      double newProgress,
    ) {
      // 更新进度
      //position.value = newPosition;
      // 拖拽进度条的时候不会更新到进度条上面
      if (!isDragProgress) {
        progress.value = newProgress;
      }
    });

    //监听长度变化
    subMusicDuration = playService.listenMusicDuration((newDuration) {
      duration.value = newDuration;
    });
  }

  /// 点击播放按钮
  void onTapPlay() {
    playService.playOrPause();
  }

  /// 点击进度条
  onTapProgress(double progress) {
    if (PlatformUtils.isPhone) {
      if (!playService.playPosition(progress)) {
        this.progress.value = 0;
      }
    }
  }
}
