import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:dm_music/core/audio/audio_player_provider.dart';
import 'package:dm_music/core/audio/play_state.dart';
import 'package:dm_music/core/models/music.dart';

/// 播放器的播放/暂停状态流。
final playerStateStreamProvider = StreamProvider<PlayerState>((ref) {
  return ref.watch(audioPlayerProvider).playerStateStream;
});

/// 播放进度流。
final positionStreamProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioPlayerProvider).positionStream;
});

/// 当前曲目时长流。
final durationStreamProvider = StreamProvider<Duration?>((ref) {
  return ref.watch(audioPlayerProvider).durationStream;
});

/// 播放队列状态流，携带当前音源（其 tag 为对应曲目）。
final sequenceStateStreamProvider = StreamProvider<SequenceState?>((ref) {
  return ref.watch(audioPlayerProvider).sequenceStateStream;
});

/// 聚合后的播放状态，供页面读取。
final playProvider = NotifierProvider<PlayNotifier, PlayState>(PlayNotifier.new);

class PlayNotifier extends Notifier<PlayState> {
  /// 播放请求代次：每次发起新播放递增，用于丢弃过期的异步请求。
  int _playGeneration = 0;

  @override
  PlayState build() {
    // 各路流变化时合并更新聚合状态，页面只需 watch 本 provider。
    ref.listen(playerStateStreamProvider, (_, next) {
      next.whenData((value) {
        if (value.processingState == ProcessingState.completed) {
          // 队列最后一首播完：just_audio 此时 playing 仍为 true，需主动 stop。
          // stop 会把 processingState 重置为 idle、playing 置 false，且保留当前曲目，
          // 因此信息卡是滑落收回而非整个消失。
          if (state.completed) return; // stop 引发的后续事件，忽略，避免重复复位。
          ref.read(audioPlayerProvider).stop();
          state = state.copyWith(
            playing: false,
            completed: true,
            position: Duration.zero,
          );
          return;
        }
        // 完成态下忽略其他残留事件，避免把归零的进度又写回去。
        if (state.completed) return;
        // 正常同步 playing。
        state = state.copyWith(playing: value.playing);
      });
    });
    ref.listen(positionStreamProvider, (_, next) {
      next.whenData((value) {
        // 播完后忽略残留的进度事件，保持进度条停在 0。
        if (state.completed) return;
        state = state.copyWith(position: value);
      });
    });
    ref.listen(durationStreamProvider, (_, next) {
      next.whenData(
        (value) => state = state.copyWith(duration: value ?? Duration.zero),
      );
    });
    ref.listen(sequenceStateStreamProvider, (_, next) {
      next.whenData((value) {
        final music = value?.currentSource?.tag;
        if (music is Music) state = state.copyWith(currentMusic: music);
      });
    });
    return const PlayState();
  }

  /// 为曲目构造边播边缓存的音源。
  ///
  /// 缓存已存在时直接指向本地文件，避免 [LockCachingAudioSource] 再次请求源站
  /// （它的 _fetch 即使缓存完整也会发网络请求）。缓存不存在时用它边播边下载。
  /// 两条路径都带上 [music] 作为 tag：官方 resolve() 返回的本地音源不带 tag，
  /// 会让切歌时的 currentMusic 丢失，所以这里手动补回。
  Future<AudioSource> _buildCacheSource(Music music) async {
    // ignore: experimental_member_use - just_audio 官方唯一的边播边缓存方案，已长期稳定。
    final source = LockCachingAudioSource(Uri.parse(music.source), tag: music);
    final cacheFile = await source.cacheFile;
    if (await cacheFile.exists()) {
      return AudioSource.uri(Uri.file(cacheFile.path), tag: music);
    }
    return source;
  }

  /// 用 [list] 替换当前播放队列，并从第 [index] 首开始播放。
  ///
  /// 正在缓冲时切歌会让 just_audio 中断上一次加载并抛
  /// [PlayerInterruptedException]（平台侧 code 'abort'），这是预期行为，
  /// 在此捕获避免冒泡成未处理异常导致崩溃。并发请求只让最后一次生效。
  Future<void> playFromList(List<Music> list, {int index = 0}) async {
    if (list.isEmpty) return;
    final generation = ++_playGeneration;
    final safeIndex = index.clamp(0, list.length - 1);
    try {
      final sources = await Future.wait(list.map(_buildCacheSource));
      // 构建音源期间又有新请求，本次已过期，放弃以免打断新播放。
      if (generation != _playGeneration) return;
      final player = ref.read(audioPlayerProvider);
      // 重播时清掉上一轮的完成标记，让进度事件重新生效。
      state = state.copyWith(completed: false);
      await player.setAudioSources(sources, initialIndex: safeIndex);
      await player.play();
    } on PlayerInterruptedException {
      // 加载被后续请求中断，属正常现象，忽略。
    }
  }

  /// 播放或暂停。
  Future<void> playOrPause() async {
    final player = ref.read(audioPlayerProvider);
    if (player.playing) {
      await player.pause();
    } else {
      // 完成态下 just_audio 直接从末尾续播，先 seek 回 0 再从头播放。
      if (state.completed) {
        state = state.copyWith(completed: false, position: Duration.zero);
        await player.seek(Duration.zero);
      }
      await player.play();
    }
  }

  /// 播放下一首。暂停时切歌后改为播放；已是最后一首则直接恢复播放当前曲目。
  Future<void> next() async {
    final player = ref.read(audioPlayerProvider);
    if (state.completed) state = state.copyWith(completed: false);
    // seekToNext 不会自动播放，且到末尾时什么都不做；用 hasNext 区分两种情况。
    if (player.hasNext) await player.seekToNext();
    // seek 不改变播放状态：暂停时切完歌主动播放，无下一首时则恢复播放当前曲目。
    if (!player.playing) await player.play();
  }

  /// 播放上一首。暂停时切歌后改为播放；已是第一首则直接恢复播放当前曲目。
  Future<void> previous() async {
    final player = ref.read(audioPlayerProvider);
    if (state.completed) state = state.copyWith(completed: false);
    // seekToPrevious 同样不会自动播放，且到开头时什么都不做。
    if (player.hasPrevious) await player.seekToPrevious();
    if (!player.playing) await player.play();
  }

  /// 跳转到指定进度，[progress] 为 0 到 1 的比例。
  Future<void> seekTo(double progress) async {
    final player = ref.read(audioPlayerProvider);
    final duration = player.duration;
    if (duration == null || duration.inMicroseconds <= 0) return;
    // 完成态下拖动进度条也要能响应，先退出完成态。
    if (state.completed) state = state.copyWith(completed: false);
    await player.seek(duration * progress.clamp(0.0, 1.0));
  }
}
