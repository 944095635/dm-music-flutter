import 'dart:async';

import 'package:dm_music/models/music.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

/// 播放服务
class PlayService extends GetxService {
  /// 播放器实例
  late AudioPlayer _player;

  /// 是否正在播放
  bool get playing => _player.playing;

  /// 是否初始化音乐
  bool get isInitMusic => _playList?.isNotEmpty == true;

  /// 播放列表
  List<Music>? _playList;

  /// 歌曲长度
  Duration get musicDuration => _player.duration ?? Duration.zero;

  /// 播放序号
  int? playIndex;

  @override
  void onInit() {
    super.onInit();
    //初始化音频服务
    _player = AudioPlayer();

    /// 播放顺序变化
    _player.currentIndexStream.listen((int? index) {
      //debugPrint("播放下标变化:${index ?? 0}");
      playIndex = index;
    });
  }

  /// 播放或者暂停
  void playOrPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  /// 获取正在播放的音乐
  Music? getPlayMusic() {
    int? index = _player.currentIndex;
    if (index != null && _playList != null && _playList!.isNotEmpty) {
      return _playList![index];
    }
    return null;
  }

  /// 获取正在播放的音乐列表
  List<Music>? getPlayList() {
    return _playList;
  }

  /// 更新播放列表
  Future updatePlayList(List<Music> list, int index) async {
    _playList = list;
    final playlist = ConcatenatingAudioSource(
      // Start loading next item just before reaching it
      useLazyPreparation: true,
      // Customise the shuffle algorithm
      shuffleOrder: DefaultShuffleOrder(),
      // Specify the playlist items
      children: list.map((e) => AudioSource.uri(Uri.parse(e.source))).toList(),
    );

    try {
      await _player.setAudioSource(
        playlist,
        initialIndex: index,
      );
    } catch (e) {
      debugPrint("设置播放列表失败,error:$e");
    }
  }

  /// 开始播放
  Future play() async {
    /// 不支持Windows版本
    //if (!Platform.isWindows) {
    _player.play();
    //}
    return null;
  }

  /// 播放音频
  Future<Duration?> playMusic(Music music) async {
    /// 不支持Windows版本
    //if (!Platform.isWindows) {
    Duration? duration = await _player.setUrl(music.source);
    _player.play();
    return duration;
    //}
  }

  /// 停止播放
  Future stop() async {
    /// 不支持Windows版本
    //if (!Platform.isWindows) {
    await _player.stop();
    //}
  }

  /// 监听播放状态变化
  StreamSubscription listenPlayerState(Function(PlayerState state) onData) {
    return _player.playerStateStream.listen((PlayerState state) {
      onData(state);
    });
  }

  /// 播放歌曲变化监听
  StreamSubscription listenMusicChange(Function(Music music) onData) {
    return _player.currentIndexStream.listen((int? index) {
      if (index != null && _playList != null) {
        Music music = _playList![index];
        onData(music);
      }
    });
  }

  /// 进度监听
  StreamSubscription listenMusicPosition(
      Function(Duration position, double progress) onData) {
    return _player.positionStream.listen((Duration newPosition) {
      // 计算百分比
      if (_player.playing && _player.duration != null) {
        double progress =
            newPosition.inMicroseconds / _player.duration!.inMicroseconds;
        onData(newPosition, progress);
      }
    });
  }

  /// 长度监听
  StreamSubscription listenMusicDuration(Function(Duration position) onData) {
    return _player.positionStream.listen((Duration newDuration) {
      onData(newDuration);
    });
  }

  /// 上一首
  void playPrevious() {
    _player.seekToPrevious();
    if (!_player.playing) {
      _player.play();
    }
  }

  /// 下一首
  void playNext() {
    _player.seekToNext();
    if (!_player.playing) {
      _player.play();
    }
  }
}
