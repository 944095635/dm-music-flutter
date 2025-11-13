import 'dart:async';
import 'package:dm_music/services/app_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dm_music/models/music.dart';
import 'package:just_audio/just_audio.dart';

/// 播放服务
class PlayService extends GetxService {
  /// App 服务
  AppService appService = Get.find();

  /// 播放器实例
  late AudioPlayer _player;

  /// 当前播放音乐
  Music? _currentMusic;
  Music? get currentMusic => _currentMusic;

  /// 播放列表
  List<Music>? _playList;

  /// 播放序号
  int _currentIndex = -1;

  @override
  void onClose() {
    _player.stop();
    _player.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    //初始化音频服务
    _player = AudioPlayer();

    // /// 播放顺序变化
    // _player.currentIndexStream.listen((int? index) {
    //   //debugPrint("播放下标变化:${index ?? 0}");
    //   playIndex = index;
    // });
  }

  /// 播放
  void play() {
    _player.play();
  }

  /// 播放或者暂停
  bool playOrPause() {
    if (_currentMusic == null) {
      return false;
    }
    if (_player.playing) {
      _player.pause();
      return false;
    } else {
      _player.play();
      return true;
    }
  }

  /// 播放音乐
  void playMusic(Music newMusic) {
    _player.setUrl(newMusic.source!);
    _player.play();
  }

  /// 播放歌曲变化监听
  StreamSubscription listenMusicChange(Function(Music music) onData) {
    return _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      if (sequenceState != null &&
          sequenceState.currentIndex != _currentIndex) {
        _currentIndex = sequenceState.currentIndex ?? -1;
        _currentMusic = _playList?[_currentIndex];
        if (_currentMusic != null) {
          onData(_currentMusic!);
        }
      }
    });
  }

  /// 监听播放状态变化
  StreamSubscription listenPlayerState(Function(PlayerState state) onData) {
    return _player.playerStateStream.listen((PlayerState state) {
      onData(state);
    });
  }

  /// 进度监听
  StreamSubscription listenMusicPosition(
    Function(Duration position, double progress) onData,
  ) {
    return _player.positionStream.listen((Duration newPosition) {
      // 计算百分比
      if (_player.playing && _player.duration != null) {
        double progress =
            newPosition.inMicroseconds / _player.duration!.inMicroseconds;
        // debugPrint("歌曲进度回调1:$progress");
        if (progress > 1) {
          progress = 1;
        } else if (progress < 0) {
          progress = 0;
        } else if (progress.isNaN) {
          progress = 0;
        }
        onData(newPosition, progress);
      }
    });
  }

  /// 长度监听
  StreamSubscription listenMusicDuration(Function(Duration position) onData) {
    return _player.durationStream.listen((Duration? newDuration) {
      if (newDuration != null) {
        onData(newDuration);
      }
    });
  }

  /// 播放跳转进度
  bool playPosition(double percentage) {
    if (_player.playing && _player.duration != null) {
      Duration position = Duration(
        seconds: (_player.duration!.inSeconds * percentage).toInt(),
      );
      _player.seek(position);
      return true;
    }
    return false;
  }

  /// 设置播放列表
  void setPlaylist(List<Music> list, {int index = 0}) async {
    _currentIndex = -1;
    _playList = list;
    try {
      //_player.stop();
      await _player.setAudioSources(
        list
            .map(
              (e) => AudioSource.uri(
                Uri.parse(e.source ?? ""),
                tag: e.name,
                headers: {"X-Nd-Authorization": "Bearer ${appService.token}"},
              ),
            )
            .toList(),
        initialIndex: index,
      );
      _player.play();
    } catch (e) {
      debugPrint("设置播放列表失败,error:$e");
    }
  }

  /// 播放上一首
  void playPrevious() {
    _player.seekToPrevious();
    if (!_player.playing) {
      _player.play();
    }
  }

  /// 播放下一首
  void playNext() {
    _player.seekToNext();
    if (!_player.playing) {
      _player.play();
    }
  }
}
