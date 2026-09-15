import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// 播放控制区域
class MusicControl extends StatelessWidget {
  const new(
    this.controller, {
    super.key,
    this.onPlayPause,
    this.onPrevious,
    this.onNext,
  });

  /// 播放按钮动画控制器
  final AnimationController controller;

  /// 播放/暂停按钮 回调
  final VoidCallback? onPlayPause;

  /// 播放上一首
  final VoidCallback? onPrevious;

  /// 播放下一首
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 15,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //上一首
        IconButton(
          onPressed: onPrevious,
          icon: HugeIcon(icon: HugeIcons.strokeRoundedPrevious),
        ),

        //播放/暂停
        //播放暂停
        GestureDetector(
          behavior: .opaque,
          onTap: onPlayPause,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: AnimatedIcon(
                size: 32,
                progress: controller,
                color: Colors.white,
                icon: AnimatedIcons.play_pause,
              ),
            ),
          ),
        ),

        // 下一首
        IconButton(
          onPressed: onNext,
          icon: HugeIcon(icon: HugeIcons.strokeRoundedNext),
        ),
      ],
    );
  }
}
