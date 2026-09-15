import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:dm_music/model/music.dart';
import 'package:dm_music/widget/blur_widget.dart';

/// 正在播放到的音乐卡片
class PlayInfoCard extends StatelessWidget {
  const PlayInfoCard(this.music, {super.key});

  /// 当前播放音乐
  final Music music;

  @override
  Widget build(BuildContext context) {
    // 顶部圆角值
    final topBorderRadius = BorderRadius.vertical(
      top: Radius.circular(20),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: topBorderRadius,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            //color: const Color.fromARGB(255, 255, 0, 0),
            //color: const Color.fromRGBO(60, 60, 60, 0.8),
            color: Colors.white.withAlpha(30),
            //color: Colors.red,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: BlurWidget(
        radius: topBorderRadius,
        child: Container(
          padding: const EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
          ),
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            borderRadius: topBorderRadius,
            border: Border(
              top: const BorderSide(
                color: Color.fromRGBO(255, 255, 255, 0.65),
              ),
            ),
            color: Color.fromRGBO(0, 0, 0, 0.5),
          ),
          child: buildContent(),
        ),
      ),
    );
  }

  /// 构建音乐信息卡片内容
  Widget buildContent() {
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
            memCacheWidth: 150,
            memCacheHeight: 150,
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
                  style: TextStyle(
                    fontWeight: .w500,
                  ),
                ),
                Text(
                  music.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: .w500,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            // // showModalBottomSheet(
            // //   context: Get.context!,
            // //   builder: (context) => const PlayListPage(),
            // // );
            // // controller.music.value!.like.value =
            // //     !controller.music.value!.like.value;
            // // static const heartBoldSvg = 'assets/svgs/heart_bold.svg';
            // // static const heartLineSvg = 'assets/svgs/heart_line.svg';
            // music.like.value = !music.like.value;
            // controller.update();
          },
          icon: HugeIcon(icon: HugeIcons.strokeRoundedFavourite),
          // icon: SvgPicture.asset(
          //   music.like.value
          //       ? 'assets/svgs/heart_bold.svg'
          //       : 'assets/svgs/heart_line.svg',
          //   colorFilter: ColorFilter.mode(
          //     music.like.value
          //         ? Colors.red
          //         : theme.colorScheme.onSurface.withAlpha(120),
          //     BlendMode.srcIn,
          //   ),
          // ),
        ),
      ],
    );
  }
}
