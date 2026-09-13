import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:inspire_blur/inspire_blur.dart';
import 'package:dm_music/values/http_keys.dart';

/// 音乐卡片
class MusicNewItem extends StatelessWidget {
  const MusicNewItem({
    super.key,
    required this.music,
    required this.author,
    required this.cover,
  });

  final String music;

  final String author;

  final String cover;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Inspire.childBlur(
            config: InspireBlurConfig.bottomToTop(
              sigma: 55,
              extent: 0.5,
              fadeCurve: Curves.easeInOutQuad,
            ),
            child: CachedNetworkImage(
              imageUrl: cover,
              fit: BoxFit.cover,
              memCacheHeight: 350,
              memCacheWidth: 350,
              httpHeaders: HttpKeys.headers,
            ),
          ),

          // Additional tint to make the fade look more pronounced
          Positioned.fill(
            child: Inspire.tint.bottomToTop(
              color: Colors.black,
              opacity: .68,
              extent: 0.5,
              curve: Curves.easeOut,
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              // color: theme.bottomSheetTheme.modalBackgroundColor!.withAlpha(
              //   100,
              // ),
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    music,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(160),
                    ),
                  ),
                  Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
