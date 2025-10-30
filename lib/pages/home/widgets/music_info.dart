import 'package:cached_network_image/cached_network_image.dart';
import 'package:dm_music/models/music.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// 音乐信息
class MusicInfo extends StatelessWidget {
  const MusicInfo(this.music, {super.key});

  final Music? music;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Row(
      spacing: 15,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: music != null
              ? CachedNetworkImage(
                  imageUrl: music!.cover,
                  width: 48,
                  height: 48,
                  fit: BoxFit.fill,
                  memCacheHeight: 150,
                  memCacheWidth: 150,
                )
              : SizedBox(
                  width: 48,
                  height: 48,
                ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                music?.name ?? "",
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                music?.author ?? "",
                style: theme.textTheme.bodySmall!.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(160),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // showModalBottomSheet(
            //   context: Get.context!,
            //   builder: (context) => const PlayListPage(),
            // );
            // controller.music.value!.like.value =
            //     !controller.music.value!.like.value;
            // static const heartBoldSvg = 'assets/svgs/heart_bold.svg';
            // static const heartLineSvg = 'assets/svgs/heart_line.svg';
          },
          icon: SvgPicture.asset(
            'assets/svgs/heart_bold.svg',
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
