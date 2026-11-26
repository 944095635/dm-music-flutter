import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

import 'package:dm_music/app/theme/app_sizes.dart';
import 'package:dm_music/core/audio/play_provider.dart';

/// 首页底部播放控制条：上一首、播放/暂停、下一首。
class PlayerControls extends ConsumerStatefulWidget {
  const PlayerControls({super.key});

  @override
  ConsumerState<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends ConsumerState<PlayerControls>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    // 播放/暂停图标切换速度：旧版是 Durations.long2(500ms)，这里慢一档。
    duration: Durations.long3,
  );

  @override
  void initState() {
    super.initState();
    // 组件出现时按当前播放状态对齐图标。
    if (ref.read(playProvider).playing) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 播放状态变化时切换播放/暂停图标。
    ref.listen(playProvider.select((state) => state.playing), (_, playing) {
      if (playing) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });

    final notifier = ref.read(playProvider.notifier);
    return Row(
      spacing: 15,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: notifier.previous,
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedPrevious,
            size: AppSizes.icon,
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: notifier.playOrPause,
          // AnimatedIcon 切换动画每帧 repaint，且这条链上到根没有天然 boundary，
          // 就地隔离可避免 repaint 冒泡到根节点造成整屏重绘。
          // 注意：extendBodyBehindAppBar=true 时 AppBar 的 BlurView 会形成整屏合成层，
          // 整屏重绘发生在合成层级别，此 boundary 挡不住、会失效；
          // 只有 extendBodyBehindAppBar=false（paint 冒泡路径）时才有效。
          child: RepaintBoundary(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: AnimatedIcon(
                  size: AppSizes.primaryIcon,
                  progress: _controller,
                  color: Colors.white,
                  icon: AnimatedIcons.play_pause,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: notifier.next,
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedNext,
            size: AppSizes.icon,
          ),
        ),
      ],
    );
  }
}
