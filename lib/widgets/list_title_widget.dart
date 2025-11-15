import 'package:dm_music/themes/dimensions.dart';
import 'package:flutter/material.dart';

/// 列表内的分类标签
class ListTitleWidget extends StatelessWidget {
  const ListTitleWidget(
    this.title, {
    super.key,
    this.trailingText,
    this.onTap,
  });

  final String title;

  final String? trailingText;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget child;

    /// 有右侧文本
    if (trailingText != null) {
      child = Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Text(
            trailingText!,
            style: TextStyle(
              color: theme.colorScheme.primary.withAlpha(150),
            ),
          ),
        ],
      );
    } else {
      child = Text(
        title,
        style: theme.textTheme.titleMedium,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(
        Dimensions.pagePadding,
      ),
      child: child,
    );
  }
}
