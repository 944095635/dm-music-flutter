import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Svg图标扩展
class SvgPictureExtensions {
  static SvgPicture asset(
    String assetName,
    Color color, {
    double iconSize = 24,
  }) {
    return SvgPicture.asset(
      assetName,
      width: iconSize,
      height: iconSize,
      colorFilter: ColorFilter.mode(
        color,
        BlendMode.srcIn,
      ),
    );
  }
}
