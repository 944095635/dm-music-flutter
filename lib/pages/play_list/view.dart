import 'package:cached_network_image/cached_network_image.dart';
import 'package:dm_music/models/music.dart';
import 'package:dm_music/widgets/blur_widget.dart';
import 'package:dm_music/widgets/highlight_widget.dart';
import 'package:dm_music/widgets/shadow_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled/radius_extension.dart';
import 'package:flutter_styled/size_extension.dart';
import 'package:get/get.dart';

import 'index.dart';

/// 播放列表
class PlayListPage extends GetView<PlayListController> {
  const PlayListPage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    BorderRadius borderRadius = BorderRadius.vertical(
      top: 10.radius,
    );
    Get.put(PlayListController());
    return SizedBox.expand(
      child: controller.obx(
        (data) => ShadowWidget(
          borderRadius: borderRadius,
          child: BlurWidget(
            borderRadius: borderRadius,
            child: HighlightWidget(
              hasTopBorder: true,
              borderRadius: borderRadius,
              backgroundColor: theme.bottomSheetTheme.modalBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: kMinInteractiveDimension,
                ),
                child: _buildPlayList(theme, data!),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 播放列表
  _buildPlayList(ThemeData theme, List<Music> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        Music music = data[index];
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: music.cover,
                  width: 46,
                  height: 46,
                  fit: BoxFit.fill,
                ),
              ),
              15.horizontalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    music.name,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(.8),
                    ),
                  ),
                  Text(
                    music.author,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(.6),
                    ),
                  ),
                  4.verticalSpace,
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
