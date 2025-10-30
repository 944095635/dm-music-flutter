import 'dart:async';

import 'package:dm_music/models/music.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

/// 播放服务
class PlayService extends GetxService {
  /// 播放器实例
  late AudioPlayer _player;

  /// 当前播放音乐
  Music? _currentMusic;
  Music? get currentMusic => _currentMusic;

  /// 播放歌曲变化的流
  final StreamController<Music?> musicStreamController =
      StreamController<Music?>.broadcast();

  Stream<Music?> get musicStream => musicStreamController.stream;

  /// 更新当前播放音乐
  void updateMusic(Music? newMusic) {
    _currentMusic = newMusic;
    musicStreamController.add(_currentMusic);
  }

  @override
  void onClose() {
    musicStreamController.close();
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
  void playMusic(Music music) {
    updateMusic(music);
    _player.setUrl(music.source!);
    _player.play();
  }

  /// 监听播放歌曲变化
  StreamSubscription listenMusicEvent(void Function(Music?)? onData) {
    return musicStream.listen(onData);
  }

  /// 监听播放状态变化
  StreamSubscription listenPlayerState(Function(PlayerState state) onData) {
    return _player.playerStateStream.listen((PlayerState state) {
      onData(state);
    });
  }
}
