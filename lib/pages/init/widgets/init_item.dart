import 'package:flutter/material.dart';
import 'package:flutter_styled/radius_extension.dart';
import 'package:get/get.dart';

/// 初始页 - 初始项
class InitItem extends StatelessWidget {
  const InitItem(
    this.name,
    this.icon,
    this.selected, {
    super.key,
    this.onTap,
  });

  final String name;

  final String icon;

  final bool selected;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    Color textColor;
    if (Get.isDarkMode) {
      textColor = theme.colorScheme.primary;
    } else if (selected) {
      textColor = theme.colorScheme.onPrimary;
    } else {
      textColor = theme.colorScheme.primary;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? theme.cardColor : null,
          borderRadius: 10.borderRadius,
          border: Border.all(
            color: theme.colorScheme.primary.withAlpha(40),
          ),
        ),
        padding: EdgeInsets.only(
          top: 20,
          bottom: 15,
        ),
        child: Column(
          spacing: 10,
          children: [
            Image.asset(
              icon,
              width: 48,
              height: 48,
            ),
            Text(
              name,
              style: TextStyle(
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
