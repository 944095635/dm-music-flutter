import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:dm_music/core/audio/play_provider.dart';
import 'package:dm_music/shared/widgets/player_slider_view.dart';

/// 播放进度条：集中订阅播放进度，滑块与时间文本共享同一数据源。
///
/// 进度推进只更新 notifier：滑块画布局部重绘、时间文本局部重建，
/// 本组件与首页都不 rebuild。拖动跟手由滑块内部处理，松手后跳转。
class PlayerProgressSlider extends ConsumerStatefulWidget {
  const PlayerProgressSlider({
    super.key,
    this.showTimeText = false,
    this.sliderType = PlayerSliderType.curve,
  });

  /// 是否显示「当前时间 / 总时长」文本，播放页可开启。
  final bool showTimeText;

  /// 轨道形态：首页迷你播放区用曲线，全屏播放页用直线。
  final PlayerSliderType sliderType;

  @override
  ConsumerState<PlayerProgressSlider> createState() =>
      _PlayerProgressSliderState();
}

class _PlayerProgressSliderState extends ConsumerState<PlayerProgressSlider> {
  /// 归一化进度，供滑块画布监听。
  final ValueNotifier<double> _progress = ValueNotifier(0);

  /// 时间文本数据，供文本局部重建。
  /// 存格式化后的字符串：秒数没变时值相等，notifier 不通知，避免无效重建。
  final ValueNotifier<({String position, String duration})> _time =
      ValueNotifier((position: _zeroTime, duration: _zeroTime));

  static const String _zeroTime = '00:00';

  @override
  void initState() {
    super.initState();
    // read 不受 build 阶段限制，先同步一次保证首帧进度正确。
    final state = ref.read(playProvider);
    _sync(state.position, state.duration);
  }

  void _sync(Duration position, Duration duration) {
    _time.value = (position: _format(position), duration: _format(duration));
    _progress.value = duration.inMicroseconds == 0
        ? 0
        : (position.inMicroseconds / duration.inMicroseconds).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _progress.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // listen 只能在 build 中注册，由 Riverpod 随 rebuild 重挂、unmount 自动关闭。
    // 用 listen 而非 watch：进度推进只更新 notifier，不触发本组件 rebuild。
    ref.listen(playProvider.select((s) => s.position), (_, position) {
      _sync(position, ref.read(playProvider).duration);
    });
    ref.listen(playProvider.select((s) => s.duration), (_, duration) {
      _sync(ref.read(playProvider).position, duration);
    });

    final slider = RepaintBoundary(
      child: PlayerSliderView(
        valueListenable: _progress,
        sliderType: widget.sliderType,
        bezier: 16,
        onChanged: (_) {
          // 拖动跟手由滑块内部处理，这里不回写，避免与播放进度流互相打断。
        },
        onChangeEnd: ref.read(playProvider.notifier).seekTo,
      ),
    );

    if (!widget.showTimeText) return slider;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: .stretch,
      children: [
        // 曲线端点贴在组件底边，滑块放最后保持曲线与控制区的相对位置不变。
        slider,
        ValueListenableBuilder<({String position, String duration})>(
          valueListenable: _time,
          builder: (_, time, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time.position),
              Text(time.duration),
            ],
          ),
        ),
      ],
    );
  }

  static String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
