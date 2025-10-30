import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// 音乐控制按钮
class MusicButtons extends StatelessWidget {
  const MusicButtons({
    super.key,
    this.onTapPlay,
    this.onTapNext,
    this.onTapPrevious,
    this.controller,
    this.onTapPlayList,
  });

  final Function()? onTapPlay;

  final Function()? onTapPlayList;

  final Function()? onTapPrevious;

  final Function()? onTapNext;

  final AnimationController? controller;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double iconSize = 36;
    return Row(
      spacing: 15,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //上一首
        IconButton(
          onPressed: onTapPrevious,
          icon: SvgPicture.asset(
            'assets/svgs/skip_previous_bold.svg',
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
        //播放暂停
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTapPlay,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.onSurface,
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: AnimatedIcon(
                size: iconSize,
                color: theme.colorScheme.primary,
                icon: AnimatedIcons.play_pause,
                progress: controller ?? AlwaysStoppedAnimation(0),
              ),
            ),
          ),
        ),
        //下一首
        IconButton(
          onPressed: onTapNext,
          icon: SvgPicture.asset(
            'assets/svgs/skip_next_bold.svg',
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}
