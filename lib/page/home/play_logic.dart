import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dm_music/model/music.dart';
import 'package:dm_music/service/play_service.dart';

/// 播放页逻辑(复用)
/// 用于播放音乐 [主页] 和 [播放页]
/// 包含播放、暂停、上一首、下一首、调整音量、调整进度等功能
class PlayLogic extends GetxController with GetSingleTickerProviderStateMixin {
  /// 当前播放的音乐
  final Rxn<Music> currentMusic = Rxn<Music>();

  /// 是否正在播放
  bool isPlaying = false;

  /// 是否正在拖动进度条
  bool isDragging = false;

  /// 当前播放进度(百分比格式)
  final RxDouble progress = 0.0.obs;

  /// 当前歌曲播放进度(用于时间显示)
  final Rx<Duration> position = Rx(Duration.zero);

  /// 当前歌曲长度
  final Rx<Duration> duration = Rx(Duration.zero);

  /// 是否显示控制组件
  AnimationController? slideController;

  /// 当前所有的订阅
  final List<StreamSubscription> subscriptions = [];

  /// 播放按钮动画控制器
  late final btnController = AnimationController(
    vsync: this,
    duration: Durations.long2,
  );

  @override
  void onInit() {
    super.onInit();
    initService();
  }

  @override
  void onClose() {
    super.onClose();

    // 销毁资源
    btnController.dispose();
    slideController?.dispose();

    // 销毁当前音乐
    currentMusic.close();

    // 销毁播放数据
    position.close();
    duration.close();
    progress.close();

    // 销毁所有订阅
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
  }

  /// 初始化服务
  void initService() async {
    // 监听播放状态变化
    subscriptions.add(PlayService.onStateChange(stateChange));

    // 监听歌曲长度变化
    subscriptions.add(PlayService.onDurationChange(durationChange));

    // 监听播放进度变化
    subscriptions.add(PlayService.onProgressChange(progressChange));
  }

  /// 监听歌曲长度变化
  void durationChange(Duration newDuration) {
    // debugPrint("歌曲长度回调:$newDuration");
    duration.value = newDuration;
  }

  /// 监听播放进度变化
  void progressChange(Duration newPosition) {
    position.value = newPosition;
    if (isDragging) return; // 正在拖动进度条，不更新播放进度

    // 计算百分比
    double newProgress =
        newPosition.inMicroseconds / duration.value.inMicroseconds;
    // debugPrint("歌曲进度回调1:$progress");
    if (newProgress > 1) {
      newProgress = 1;
    } else if (newProgress < 0) {
      newProgress = 0;
    } else if (newProgress.isNaN) {
      newProgress = 0;
    }
    progress.value = newProgress;
  }

  /// 播放状态改变
  void stateChange(bool playing) {
    isPlaying = playing;
    debugPrint("歌曲状态回调:$playing");
    if (playing) {
      slideController?.forward();
      btnController.forward();
    } else {
      slideController?.reverse();
      btnController.reverse();
    }
  }

  /// 播放音乐
  void playMusic(Music music) {
    isPlaying = true;
    currentMusic.value = music;
    PlayService.play(music.source);
    update();
  }

  /// 播放或者暂停
  void playPause() {
    PlayService.playOrPause();
  }

  void playPrevious() {}

  void playNext() {}

  /// 点击进度条
  void onTapProgress(double value) async {
    final state = await PlayService.seekPosition(value);
    if (!state) {
      progress.value = 0;
    }
  }
}
