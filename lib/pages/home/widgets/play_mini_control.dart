import 'package:dm_music/extension/svg_picture_extensions.dart';
import 'package:dm_music/index.dart';
import 'package:dm_music/widgets/play_control_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';

/// 播放器控制组件 - 迷你
class PlayMiniControl extends PlayControlWidget {
  const PlayMiniControl({
    super.key,
    super.onTapPlayList,
    required super.onTapPlay,
    required super.onTapNext,
    required super.onTapPrevious,
    required super.controller,
  });

  @override
  State<PlayMiniControl> createState() => _PlayMiniControlState();
}

class _PlayMiniControlState extends State<PlayMiniControl> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double iconSize = 36;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //上一首
        IconButton(
          onPressed: widget.onTapPrevious,
          icon: SvgPictureExtensions.asset(
            AssetsSvgs.skipPreviousBoldSvg,
            theme.colorScheme.onSurface,
            iconSize: iconSize,
          ),
        ),
        15.horizontalSpace,
        //播放暂停
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTapPlay,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(
                  AssetsImages.buttonPlayPng,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: AnimatedIcon(
                size: iconSize,
                icon: AnimatedIcons.play_pause,
                color: Colors.black,
                progress: widget.controller,
              ),
            ),
          ),
        ),
        15.horizontalSpace,
        //下一首
        IconButton(
          onPressed: widget.onTapNext,
          icon: SvgPictureExtensions.asset(
            AssetsSvgs.skipNextBoldSvg,
            theme.colorScheme.onSurface,
            iconSize: iconSize,
          ),
        ),
      ],
    );
  }
}
