import 'dart:async';
import 'package:media_kit/media_kit.dart';

/// 播放服务
class PlayService {
  // 播放组件
  static final Player _player = Player();

  /// 监听播放状态变化
  static StreamSubscription<bool> onStateChange(
    void Function(bool playing) stateChange,
  ) {
    return _player.stream.playing.listen(stateChange);
  }

  /// 监听播放进度变化
  static StreamSubscription<Duration> onProgressChange(
    void Function(Duration)? onData,
  ) {
    return _player.stream.position.listen(onData);
  }

  /// 监听歌曲长度变化
  static StreamSubscription<Duration> onDurationChange(
    void Function(Duration newDuration) durationChange,
  ) {
    return _player.stream.duration.listen(durationChange);
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

  /// 播放一个音乐文件
  static Future<void> play(String source) {
    return _player.open(Media(source));
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
}
