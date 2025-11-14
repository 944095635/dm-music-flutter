import 'package:flutter/material.dart';
import 'package:flutter_styled/radius_extension.dart';

/// 卡片组件，选中后拥有颜色
class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    this.padding,
    required this.child,
    required this.selected,
  });

  final bool selected;

  final Widget child;

  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: selected ? theme.cardColor : null,
        borderRadius: 10.borderRadius,
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(20),
        ),
      ),
      padding: padding ?? EdgeInsets.all(10),
      child: child,
    );
  }
}
