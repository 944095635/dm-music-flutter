import 'dart:async';
import 'dart:convert';
import 'package:dm_music/apis/navidrome_api.dart';
import 'package:dm_music/helpers/cache_helper.dart';
import 'package:dm_music/models/login_data/navidrome_data.dart';
import 'package:dm_music/models/music.dart';
import 'package:dm_music/models/music_lrc.dart';
import 'package:dm_music/models/music_source.dart';
import 'package:dm_music/services/play_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/core/lyric_model.dart';
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:get/get.dart';

/// 播放逻辑
class PlayLogic extends GetxController with GetSingleTickerProviderStateMixin {
  /// 播放服务
  final PlayService playService = Get.find();

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
  late LyricController lrcController;

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

    lrcController = LyricController();

    //监听歌曲变化
    subMusicChange = playService.listenMusicChange((newMusic) {
      music = newMusic;
      progress.value = 0;
      lrcController.setProgress(Duration.zero);
      // 加载歌词
      loadLrc();
      debugPrint("歌曲切换回调:${newMusic.name}");
      update();
    });

    //监听播放状态变化
    subPlayerState = playService.listenPlayerState((playing) {
      debugPrint("歌曲状态回调:$playing");
      if (playing) {
        slideController?.forward();
        playButtonController.forward();
      } else {
        slideController?.reverse();
        playButtonController.reverse();
      }
    });

    //监听进度变化
    subMusicPosition = playService.listenMusicPosition((Duration newPosition) {
      // debugPrint("歌曲进度回调:$newPosition");
      // 更新进度
      position.value = newPosition;
      lrcController.setProgress(newPosition);
      // 拖拽进度条的时候不会更新到进度条上面
      if (!isDragProgress) {
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
        //debugPrint("歌曲进度回调:$newProgress");
      }
    });

    //监听长度变化
    subMusicDuration = playService.listenMusicDuration((newDuration) {
      // debugPrint("歌曲长度回调:$newDuration");
      duration.value = newDuration;
    });
  }

  /// 点击播放按钮
  void onTapPlay() {
    playService.playOrPause();
  }

  /// 点击进度条
  void onTapProgress(double progress) async {
    bool state = await playService.playPosition(progress);
    if (!state) {
      this.progress.value = 0;
    }
  }

  /// 点击上一首按钮
  void onTapPrevious() {
    playService.playPrevious();
  }

  /// 点击下一首按钮
  void onTapNext() {
    playService.playNext();
  }

  /// 加载歌词
  void loadLrc() async {
    if (music != null) {
      MusicSource? source = await CacheHelper.getSource();
      if (source != null && source.type == MusicSourceType.navidrome) {
        var data = NavidromeData.fromJson(source.data);
        var result = await NavidromeApi.getSong1(
          data: data,
          id: music?.id ?? "",
        );
        if (result.status && result.data != null) {
          if (result.data is Map) {
            String lyricsStr = result.data["lyrics"];
            List lyrics = json.decode(lyricsStr);
            if (lyrics.isNotEmpty) {
              var lrcModel = MusicLrc.fromJson(lyrics.first);
              List<LyricLine> lines = List.empty(growable: true);
              for (var lrc in lrcModel.line) {
                lines.add(
                  LyricLine(
                    start: Duration(milliseconds: lrc.start),
                    text: lrc.value,
                  ),
                );
              }
              lrcController.loadLyricModel(LyricModel(lines: lines));
            }
          }
        }
      } else if (source != null && source.type == MusicSourceType.dmusic) {
        if (music!.name.contains("光年之外")) {
          loadAssetsLrc('assets/lrcs/光年之外.lrc');
        } else if (music!.name.contains("是一场烟火")) {
          loadAssetsLrc('assets/lrcs/是一场烟火.lrc');
        } else if (music!.name.contains("Nu")) {
          loadAssetsLrc('assets/lrcs/Nu.lrc');
        } else {
          lrcController.stopSelection();
          lrcController.loadLyricModel(
            LyricModel(
              lines: [LyricLine(start: Duration.zero, text: "暂无歌词")],
            ),
          );
        }
      }
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
