import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:dm_music/model/music.dart';

/// 播放服务
class PlayService {
  // 播放组件
  static final Player _player = Player();

  /// 播放列表
  static List<Music>? _playList;

  /// 监听播放状态变化
  static StreamSubscription<bool> onStateChange(
    void Function(bool playing) stateChange,
  ) {
    return _player.stream.playing.listen(stateChange);
  }

  /// 监听歌曲切换
  static StreamSubscription<dynamic> onMusicChange(
    void Function(Music? music) musicChange,
  ) {
    return _player.stream.playlist.listen((e) {
      musicChange(_playList?[e.index]);
    });
  }

  /// 监听播放进度变化
  static StreamSubscription<Duration> onProgressChange(
    void Function(Duration)? progressChange,
  ) {
    return _player.stream.position.listen(progressChange);
  }

  /// 监听歌曲长度变化
  static StreamSubscription<Duration> onDurationChange(
    void Function(Duration newDuration) durationChange,
  ) {
    return _player.stream.duration.listen(durationChange);
  }

  /// 播放一个音乐文件
  static Future<void> play() {
    return _player.play();
  }

  static Future<void> playMusic(String source) {
    return _player.open(Media(source));
  }

  /// 设置播放列表
  static Future<void> setPlaylist(
    List<Music> list, {
    int index = 0,
    bool autoplay = false,
  }) async {
    try {
      _playList = list;
      _player.open(
        Playlist(list.map((e) => Media(e.source)).toList(), index: index),
        play: autoplay,
      );
    } catch (e) {
      debugPrint("设置播放列表失败,error:$e");
    }
  }

  /// 播放跳转进度
  static Future<bool> seekPosition(double percentage) async {
    if (_player.state.playing) {
      int seconds = (_player.state.duration.inSeconds * percentage).toInt();
      await _player.seek(Duration(seconds: seconds));
      return true;
    }
    return false;
  }

  /// 播放或者暂停
  static bool playOrPause() {
    if (_player.state.playing) {
      _player.pause();
      return false;
    } else {
      _player.play();
      return true;
    }
  }

  /// 播放上一首
  static void playPrevious() {
    _player.previous();
    if (!_player.state.playing) {
      _player.play();
    }
  }

  /// 播放下一首
  static void playNext() {
    _player.next();
    if (!_player.state.playing) {
      _player.play();
    }
  }
}
