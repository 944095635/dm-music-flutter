import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:inspire_blur/inspire_blur.dart';
import 'package:dm_music/value/http_keys.dart';

/// 热门音乐项
class MusicHotItem extends StatelessWidget {
  const new({
    super.key,
    this.performance = true,
    required this.name,
    required this.author,
    required this.cover,
  });

  /// 是否开启性能模式
  final bool performance;

  /// 音乐名称
  final String name;

  /// 音乐作者
  final String author;

  /// 封面
  final String cover;

  @override
  Widget build(BuildContext context) {
    // 封面
    final imageWidget = CachedNetworkImage(
      fit: .cover,
      memCacheHeight: 350,
      imageUrl: cover,
      httpHeaders: HttpKeys.headers,
    );

    // shaderCallback: (Rect bounds) {
    //     return LinearGradient(
    //       begin: .topCenter,
    //       end: .bottomCenter,
    //       stops: [.3, 1],
    //       colors: [
    //         Color.fromRGBO(255, 255, 255, 1),
    //         Color.fromRGBO(0, 0, 0, 1),
    //       ],
    //     ).createShader(bounds);
    //   },

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: .expand,
        children: [
          // 判断是否开启模糊
          if (performance) ...{
            imageWidget,

            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, .85, 1],
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                    Colors.black,
                  ],
                ),
              ),
            ),
          } else ...{
            Inspire.childBlur(
              mode: .imageFilter,
              config: InspireBlurConfig.bottomToTop(
                sigma: 30,
                extent: 0.55,
                fadeCurve: Curves.easeInOutQuad,
              ),
              child: imageWidget,
            ),
            Inspire.tint.bottomToTop(
              color: Colors.black,
              opacity: .8,
              extent: 0.6,
              curve: Curves.easeOut,
            ),
          },

          // 歌曲名称和作者
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: .end,
              crossAxisAlignment: .start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  author,
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
