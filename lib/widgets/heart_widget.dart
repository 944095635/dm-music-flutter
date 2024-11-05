import 'package:dm_music/extension/svg_picture_extensions.dart';
import 'package:dm_music/index.dart';
import 'package:flutter/material.dart';

/// 心 ♥ 组件
class HeartWidget extends StatelessWidget {
  const HeartWidget({
    super.key,
    required this.like,
  });

  final bool like;

  @override
  Widget build(BuildContext context) {
    Color color;
    String svg;
    if (like) {
      svg = AssetsSvgs.heartBoldSvg;
      color = Colors.red;
    } else {
      svg = AssetsSvgs.heartLineSvg;
      color = Theme.of(context).colorScheme.onSurface;
    }
    return SvgPictureExtensions.asset(svg, color);
  }
}
