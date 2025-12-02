import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dm_music/models/music.dart';
import 'package:media_kit/media_kit.dart';

/// 播放服务
class PlayService extends GetxService {
  // 播放组件
  late final _player = Player();

  /// 播放列表
  List<Music>? _playList;

  @override
  void onClose() {
    _player.stop();
    _player.dispose();
    super.onClose();
  }

  /// 播放
  void play() {
    _player.play();
  }

  /// 播放或者暂停
  bool playOrPause() {
    if (_player.state.playing) {
      _player.pause();
      return false;
    } else {
      _player.play();
      return true;
    }
  }

  /// 播放歌曲变化监听
  StreamSubscription listenMusicChange(Function(Music music) onData) {
    return _player.stream.playlist.listen((e) {
      onData(_playList![e.index]);
    });
  }

  /// 监听播放状态变化
  StreamSubscription listenPlayerState(Function(bool state) onData) {
    return _player.stream.playing.listen(onData);
  }

  /// 进度监听
  StreamSubscription listenMusicPosition(Function(Duration position) onData) {
    return _player.stream.position.listen(onData);
  }

  /// 长度监听
  StreamSubscription listenMusicDuration(Function(Duration duration) onData) {
    return _player.stream.duration.listen(onData);
  }

  /// 设置播放列表
  void setPlaylist(List<Music> list, {int index = 0}) async {
    try {
      _playList = list;
      _player.open(
        Playlist(list.map((e) => Media(e.source ?? "")).toList(), index: index),
      );
    } catch (e) {
      debugPrint("设置播放列表失败,error:$e");
    }
  }

  /// 播放跳转进度
  Future<bool> playPosition(double percentage) async {
    if (_player.state.playing) {
      int seconds = (_player.state.duration.inSeconds * percentage).toInt();
      await _player.seek(Duration(seconds: seconds));
      return true;
    }
    return false;
  }

  /// 播放上一首
  void playPrevious() {
    _player.previous();
    if (!_player.state.playing) {
      _player.play();
    }
  }

  /// 播放下一首
  void playNext() {
    _player.next();
    if (!_player.state.playing) {
      _player.play();
    }
  }
}
