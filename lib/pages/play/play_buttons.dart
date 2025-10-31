import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// 音乐控制按钮
class PlayButtons extends StatelessWidget {
  const PlayButtons({
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
    double iconSize = 32;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //循环模式
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            'assets/svgs/music_repeat.svg',
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
        //上一首
        IconButton(
          onPressed: onTapPrevious,
          icon: SvgPicture.asset(
            'assets/svgs/skip_previous.svg',
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
              border: Border.all(
                width: 1.8,
                color: theme.colorScheme.onSurface,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: AnimatedIcon(
                size: 36,
                color: theme.colorScheme.onSurface,
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
            "assets/svgs/skip_next.svg",
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
        //播放列表
        IconButton(
          onPressed: onTapPlayList,
          icon: SvgPicture.asset(
            'assets/svgs/music_playlist_bold.svg',
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
