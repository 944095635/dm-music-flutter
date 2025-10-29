import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MusicControl extends StatelessWidget {
  const MusicControl({
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
            color: theme.colorScheme.onSurface,
            width: iconSize,
            height: iconSize,
          ),
        ),
        //播放暂停
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTapPlay,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/button_play.png'),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: AnimatedIcon(
                size: iconSize,
                icon: AnimatedIcons.play_pause,
                color: Colors.black,
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
            color: theme.colorScheme.onSurface,
            width: iconSize,
            height: iconSize,
          ),
        ),
      ],
    );
  }
}
