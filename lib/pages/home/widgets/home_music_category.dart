import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/radius_extension.dart';

class HomeMusicCategory extends StatelessWidget {
  const HomeMusicCategory(
    this.title,
    this.subTitle,
    this.logo, {
    super.key,
  });

  final String title;

  final String subTitle;

  final String logo;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget logoWidget;
    if (logo.startsWith("http")) {
      // 远程图片地址
      logoWidget = CachedNetworkImage(
        imageUrl: logo,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      );
    } else {
      logoWidget = Image.asset(
        logo,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      );
    }

    return Row(
      spacing: 12,
      children: [
        ClipRRect(
          borderRadius: 5.borderRadius,
          child: logoWidget,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(200),
                ),
              ),
              Text(
                subTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(160),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
