import 'dart:async';

import 'package:dm_music/models/music.dart';
import 'package:dm_music/services/play_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

/// 播放页面共用逻辑
/// 包括
/// ---- 当前播放的歌曲信息[ 歌曲名称 作者 封面 ]
/// ---- 当前播放的歌曲[ 进度 总时长 ]
/// ---- 当前播放操作[ 上一首 下一首 播放&暂停 ] 👌
/// ---- 当前播放订阅[ 歌曲变化 进度变化 状态变化 ]
/// ---- 当前订阅销毁
mixin PlayMixin on GetSingleTickerProviderStateMixin {
  /// 当前播放音乐
  late final Rxn<Music> music = Rxn();

  /// 播放按钮动画控制器
  late AnimationController playController;

  /// 当前进度
  var progress = 0.0.obs;

  /// 当前正在拖动进度条
  var dragProgress = false;

  /// 当前歌曲播放进度
  final Rx<Duration> position = Rx(Duration.zero);

  /// 当前歌曲长度
  final Rx<Duration> duration = Rx(Duration.zero);

  /// 订阅播放状态
  StreamSubscription? subPlayerState;

  /// 订阅歌曲切换
  StreamSubscription? subMusicChange;

  /// 订阅播放进度
  StreamSubscription? subMusicPosition;

  /// 订阅播放长度
  StreamSubscription? subMusicDuration;

  @override
  void onInit() {
    super.onInit();

    playController = AnimationController(vsync: this)
      ..duration = Durations.long2;

    PlayService playService = Get.find<PlayService>();
    //监听播放状态变化
    subPlayerState = playService.listenPlayerState(_onPlayerState);
    //监听歌曲变化
    subMusicChange = playService.listenMusicChange(_onMusicChange);
    //监听进度变化
    subMusicPosition = playService.listenMusicPosition(_onMusicPosition);
    //监听长度变化
    subMusicDuration = playService.listenMusicDuration(_onMusicDuration);
  }

  /// 销毁事件
  void close() {
    //销毁媒体
    music.dispose();
    //取消订阅
    subPlayerState?.cancel();
    subMusicChange?.cancel();
    subMusicPosition?.cancel();
    subMusicDuration?.cancel();
    //销毁动画控制器
    playController.dispose();
    //销毁进度监听
    progress.dispose();
    position.dispose();
    duration.dispose();
  }

  /// 播放状态变化
  _onPlayerState(PlayerState state) {
    if (state.playing) {
      // 切换到暂停状态
      playController.forward();
    } else {
      // 切换到播放状态
      playController.reverse();
    }
  }

  /// 歌曲变化
  _onMusicChange(Music newMusic) {
    /// 更新歌曲
    music.value = newMusic;
  }

  /// 歌曲进度变化
  _onMusicPosition(Duration newPosition, double newProgress) {
    // 更新进度
    position.value = newPosition;
    // 拖拽进度条的时候不会更新到进度条上面
    if (!dragProgress) {
      progress.value = newProgress;
    }
  }

  /// 歌曲长度变化
  _onMusicDuration(Duration newDuration) {
    duration.value = newDuration;
  }

  /// 点击播放暂停按钮
  bool onTapPlay() {
    PlayService playService = Get.find<PlayService>();
    return playService.playOrPause();
  }

  /// 点击上一首
  onTapPrevious() {
    progress.value = 0;
    PlayService playService = Get.find<PlayService>();
    playService.playPrevious();
  }

  /// 点击下一首
  onTapNext() {
    progress.value = 0;
    PlayService playService = Get.find<PlayService>();
    playService.playNext();
  }

  /// 点击进度条
  onTapProgress(double progress) {
    PlayService playService = Get.find<PlayService>();
    playService.playPosition(progress);
  }
}
