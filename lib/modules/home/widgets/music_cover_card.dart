import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

/// 推荐音乐卡片：圆角封面铺底，底部用渐变遮罩压暗，叠加歌名与作者。
///
/// 卡片自身不固定尺寸，由外部布局决定。
class MusicCoverCard extends StatelessWidget {
  const MusicCoverCard({
    super.key,
    required this.name,
    required this.author,
    required this.cover,
  });

  /// 音乐名称。
  final String name;

  /// 音乐作者。
  final String author;

  /// 封面图地址。
  final String cover;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            fit: BoxFit.cover,
            memCacheHeight: 350,
            imageUrl: cover,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.85, 1],
                colors: [
                  Colors.transparent,
                  Colors.black87,
                  Colors.black,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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
