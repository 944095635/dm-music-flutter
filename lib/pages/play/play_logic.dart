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
import 'package:get/get.dart';

/// 播放逻辑
class PlayLogic extends GetxController with GetSingleTickerProviderStateMixin {
  /// 播放服务
  final PlayService playService = Get.find();

  /// 显示歌词
  final RxBool displayLrc = RxBool(false);

  /// 歌词
  final Rxn<MusicLrc> lrc = Rxn();

  /// 歌词当前行
  final RxInt lrcLineIndex = RxInt(0);

  /// 当前播放音乐
  final Rxn<Music> music = Rxn<Music>();

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

    //监听歌曲变化
    subMusicChange = playService.listenMusicChange((newMusic) {
      music.value = newMusic;
      // 加载歌词
      _initLyrics();
      debugPrint("歌曲切换回调:${newMusic.name}");
    });

    //监听播放状态变化
    subPlayerState = playService.listenPlayerState((state) {
      // switch (state.processingState) {
      //   case ProcessingState.idle:
      //     debugPrint("歌曲状态回调:idle");
      //     break;
      //   case ProcessingState.loading:
      //     debugPrint("歌曲状态回调:loading");
      //     break;
      //   case ProcessingState.buffering:
      //     debugPrint("歌曲状态回调:buffering");
      //     break;
      //   case ProcessingState.ready:
      //     debugPrint("歌曲状态回调:ready");
      //     break;
      //   case ProcessingState.completed:
      //     debugPrint("歌曲状态回调:completed");
      //     break;
      // }

      if (state.playing) {
        slideController?.forward();
        playButtonController.forward();
      } else {
        slideController?.reverse();
        playButtonController.reverse();
      }
    });

    //监听进度变化
    subMusicPosition = playService.listenMusicPosition((
      Duration newPosition,
      double newProgress,
    ) {
      // 更新进度
      position.value = newPosition;
      // 拖拽进度条的时候不会更新到进度条上面
      if (!isDragProgress) {
        progress.value = newProgress;
        //debugPrint("歌曲进度回调:$newProgress");
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
    if (!playService.playPosition(progress)) {
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

  /// 初始化歌词
  void _initLyrics() async {
    lrc.value = null;
    Music? music1 = music.value;
    if (music1 != null) {
      MusicSource? source = await CacheHelper.getSource();
      if (source != null && source.type == MusicSourceType.navidrome) {
        var data = NavidromeData.fromJson(source.data);
        var result = await NavidromeApi.getSong1(
          data: data,
          id: music1.id ?? "",
        );
        if (result.status && result.data != null) {
          if (result.data is Map) {
            String lyricsStr = result.data["lyrics"];
            List lyrics = json.decode(lyricsStr);
            lrc.value = MusicLrc.fromJson(lyrics.first);
            debugPrint("歌词：${lrc.value}");
          }
        }
      }
    }
  }

  /// 显示歌词
  void onTapLrc() {
    displayLrc.value = !displayLrc.value;
  }
}
