import 'package:dm_music/core/models/music.dart';

/// 聚合播放器各路信息的播放状态，供页面一次读取。
class PlayState {
  const PlayState({
    this.playing = false,
    this.completed = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentMusic,
  });

  /// 是否正在播放。
  final bool playing;

  /// 播放队列是否已播完（最后一首结束且没有下一首）。
  final bool completed;

  /// 当前播放进度。
  final Duration position;

  /// 当前曲目总时长。
  final Duration duration;

  /// 当前曲目，供播放信息卡展示；无曲目时为 null。
  final Music? currentMusic;

  PlayState copyWith({
    bool? playing,
    bool? completed,
    Duration? position,
    Duration? duration,
    Music? currentMusic,
  }) {
    return PlayState(
      playing: playing ?? this.playing,
      completed: completed ?? this.completed,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentMusic: currentMusic ?? this.currentMusic,
    );
  }
}
