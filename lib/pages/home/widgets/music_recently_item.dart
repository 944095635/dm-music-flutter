import 'package:cached_network_image/cached_network_image.dart';
import 'package:dm_music/models/music.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/size_extension.dart';

/// 最近播放子项
class MusicRecentlyItem extends StatelessWidget {
  const MusicRecentlyItem(this.music, {super.key});

  final Music music;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SizedBox(
      width: 155,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  memCacheHeight: 350,
                  memCacheWidth: 350,
                  imageUrl: music.cover,
                ),
              ),
            ),
          ),
          5.verticalSpace,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              music.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(200),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              music.author ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(160),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
