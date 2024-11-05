import 'package:flutter/material.dart';

/// 高亮组件 - 亮色边框
class HighlightWidget extends StatelessWidget {
  const HighlightWidget({
    super.key,
    this.child,
    this.hasTopBorder = false,
    this.hasBottomBorder = false,
    this.backgroundColor,
    this.borderRadius = BorderRadius.zero,
  });

  final BorderRadius borderRadius;

  final bool hasTopBorder;

  final bool hasBottomBorder;

  final Widget? child;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border(
          top: hasTopBorder
              ? const BorderSide(
                  color: Color.fromRGBO(255, 255, 255, 0.5),
                )
              : BorderSide.none,
          bottom: hasBottomBorder
              ? const BorderSide(
                  color: Color.fromRGBO(255, 255, 255, 0.5),
                )
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}
