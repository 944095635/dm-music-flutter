import 'package:cached_network_image/cached_network_image.dart';
import 'package:dm_music/models/music.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

/// 音乐信息
class MusicInfo extends StatelessWidget {
  const MusicInfo(this.music, {super.key});

  final Music music;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Row(
      spacing: 15,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: music.cover,
            width: 45,
            height: 45,
            fit: BoxFit.fill,
            memCacheHeight: 150,
            memCacheWidth: 150,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  music.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  music.author ?? "",
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(160),
                  ),
                ),
              ],
            ),
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
            music.like.value = !music.like.value;
          },
          icon: Obx(
            () => SvgPicture.asset(
              music.like.value
                  ? 'assets/svgs/heart_bold.svg'
                  : 'assets/svgs/heart_line.svg',
              colorFilter: ColorFilter.mode(
                music.like.value
                    ? Colors.red
                    : theme.colorScheme.onSurface.withAlpha(120),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
