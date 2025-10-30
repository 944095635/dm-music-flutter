import 'dart:ui';
import 'package:flutter/material.dart';

/// 模糊组件
class BlurWidget extends StatelessWidget {
  const BlurWidget({
    super.key,
    this.child,
    this.sigmaX = 15,
    this.sigmaY = 15,
    this.radius = BorderRadius.zero,
  });

  final double sigmaX;

  final double sigmaY;

  final Widget? child;

  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.bottomSheetTheme.modalBackgroundColor,
          ),
          child: child,
        ),
      ),
    );
  }
}
