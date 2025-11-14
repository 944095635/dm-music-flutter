import 'package:dm_music/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FrameEndDrawerItem extends StatelessWidget {
  const FrameEndDrawerItem(
    this.name,
    this.icon,
    this.selected, {
    super.key,
    this.onTap,
    required this.tag,
  });

  final String name;

  final String tag;

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
      child: CardWidget(
        selected: selected,
        child: Row(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              icon,
              width: 48,
              height: 48,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                  Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
