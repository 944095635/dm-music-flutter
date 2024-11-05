import 'package:dm_music/extension/svg_picture_extensions.dart';
import 'package:dm_music/index.dart';
import 'package:dm_music/widgets/play_control_widget.dart';
import 'package:flutter/material.dart';

/// 播放器控制组件
class PlayControl extends PlayControlWidget {
  const PlayControl({
    super.key,
    super.onTapPlayList,
    required super.onTapPlay,
    required super.onTapNext,
    required super.onTapPrevious,
    required super.controller,
  });

  @override
  State<PlayControl> createState() => _PlayControlState();
}

class _PlayControlState extends State<PlayControl> {
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
          icon: SvgPictureExtensions.asset(
            AssetsSvgs.musicRepeatSvg,
            Theme.of(context).colorScheme.onSurface,
            iconSize: 26,
          ),
        ),
        //上一首
        IconButton(
          onPressed: widget.onTapPrevious,
          icon: SvgPictureExtensions.asset(
            AssetsSvgs.skipPreviousSvg,
            Theme.of(context).colorScheme.onSurface,
            iconSize: iconSize,
          ),
        ),
        //播放暂停
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTapPlay,
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
                icon: AnimatedIcons.play_pause,
                color: theme.colorScheme.onSurface,
                progress: widget.controller,
              ),
            ),
          ),
        ),
        //下一首
        IconButton(
          onPressed: widget.onTapNext,
          icon: SvgPictureExtensions.asset(
            AssetsSvgs.skipNextSvg,
            Theme.of(context).colorScheme.onSurface,
            iconSize: iconSize,
          ),
        ),
        //播放列表
        IconButton(
          onPressed: widget.onTapPlayList,
          icon: SvgPictureExtensions.asset(
            AssetsSvgs.musicPlaylistBoldSvg,
            Theme.of(context).colorScheme.onSurface,
            iconSize: 24,
          ),
        ),
      ],
    );
  }
}
