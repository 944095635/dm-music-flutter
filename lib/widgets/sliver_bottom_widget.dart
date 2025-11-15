import 'package:dm_music/themes/dimensions.dart';
import 'package:flutter/material.dart';

/// Sliver 底部组件
class SliverBottomWidget extends StatelessWidget {
  const SliverBottomWidget({
    super.key,
    required this.child,
  });

  static button(String text, {VoidCallback? onPressed}) {
    return SliverBottomWidget(
      child: FilledButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  /// 子元素
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: Dimensions.pagePadding,
              right: Dimensions.pagePadding,
              bottom: Dimensions.pagePadding,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
