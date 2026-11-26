import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// 全局唯一的播放器实例，供首页迷你播放器与播放页共用。
///
/// 由 Provider 持有生命周期，应用退出（ProviderScope 销毁）时统一释放。
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});
