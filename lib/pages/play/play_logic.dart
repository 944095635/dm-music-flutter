import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:get/get.dart';
import 'package:dm_music/models/music.dart';

/// 播放逻辑
class PlayLogic extends GetxController with GetSingleTickerProviderStateMixin {
  /// 显示歌词
  final RxBool displayLrc = RxBool(false);

  /// 歌词当前行
  final RxInt lrcLineIndex = RxInt(0);

  /// 当前播放音乐
  Music? music;

  /// 当前进度
  final RxDouble progress = 0.0.obs;

  /// 当前正在拖动进度条
  bool isDragProgress = false;

  /// 当前歌曲播放进度
  final Rx<Duration> position = Rx(Duration.zero);

  /// 当前歌曲长度
  final Rx<Duration> duration = Rx(Duration.zero);

  /// 是否显示控制组件
  AnimationController? slideController;

  /// 播放按钮动画控制器
  late AnimationController playButtonController;

  /// 歌词控制器
  late final LyricController lrcController = LyricController();

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
    // 取消订阅
    subPlayerState?.cancel();
    subMusicPosition?.cancel();
    subMusicDuration?.cancel();

    // 销毁动画控制器
    lrcController.dispose();
    slideController?.dispose();
    playButtonController.dispose();

    // 销毁进度监听
    progress.close();
    // position.close();
    duration.close();

    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    playButtonController = AnimationController(vsync: this)
      ..duration = Durations.long2;
  }

  /// 点击播放按钮
  void onTapPlay() {}

  /// 点击进度条
  void onTapProgress(double progress) async {}

  /// 点击上一首按钮
  void onTapPrevious() {}

  /// 点击下一首按钮
  void onTapNext() {}

  /// 加载歌词
  void loadLrc() async {
    if (music != null) {
      // MusicSource? source = await CacheHelper.getString(CacheKeys.language);
      // if (source != null && source.type == MusicSourceType.dmusic) {
      //   if (music!.name.contains("光年之外")) {
      //     loadAssetsLrc('assets/lrcs/光年之外.lrc');
      //   } else if (music!.name.contains("是一场烟火")) {
      //     loadAssetsLrc('assets/lrcs/是一场烟火.lrc');
      //   } else if (music!.name.contains("Nu")) {
      //     loadAssetsLrc('assets/lrcs/Nu.lrc');
      //   } else {
      //     lrcController.stopSelection();
      //     lrcController.loadLyricModel(
      //       LyricModel(
      //         lines: [LyricLine(start: Duration.zero, text: "暂无歌词")],
      //       ),
      //     );
      //   }
      // }
    }
  }

  void loadAssetsLrc(String lrc) async {
    // 读取光年之外.lrc
    final String lrcStr = await DefaultAssetBundle.of(
      Get.context!,
    ).loadString(lrc);
    if (lrcStr.isNotEmpty) {
      lrcController.loadLyric(lrcStr);
    }
  }

  /// 显示歌词
  void onTapLrc() {
    displayLrc.value = !displayLrc.value;
    update();
  }
}
