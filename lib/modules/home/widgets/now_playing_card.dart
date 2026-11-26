import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:dm_music/app/routes/app_router.dart';
import 'package:dm_music/app/routes/app_routes.dart';
import 'package:dm_music/app/theme/app_sizes.dart';
import 'package:dm_music/core/audio/play_provider.dart';
import 'package:dm_music/core/favorites/favorites_provider.dart';
import 'package:dm_music/shared/widgets/blur_view.dart';

/// 首页底部播放区的信息卡：展示当前曲目的封面、歌名与作者，并可切换喜欢状态。
class NowPlayingCard extends ConsumerWidget {
  const NowPlayingCard({super.key});

  /// 喜欢贴图路径：实心表示已收藏，空心描边表示未收藏。
  static const String _favoriteFilledAsset =
      'assets/images/favorite_filled.webp';
  static const String _favoriteOutlineAsset =
      'assets/images/favorite_outline.webp';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 订阅下沉到这里：切歌只重建本卡，不再牵动整个 HomeView。
    final music = ref.watch(
      playProvider.select((state) => state.currentMusic),
    );
    // HomeView 用 hasMusic 判断是否挂载本卡，这里理论上不会为 null；
    // 仍做兜底，避免竞态下取到空曲目时崩溃。
    if (music == null) return const SizedBox.shrink();

    final topRadius = BorderRadius.vertical(top: const Radius.circular(20));
    // 只订阅收藏集合的派生布尔值：其他曲目收藏变化时本卡不重建。
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (state) => state.value?.contains(music.source) ?? false,
      ),
    );

    // 整卡点击进入全屏播放页。收藏按钮等子控件的点击会优先命中自身，
    // 不会冒泡到这里触发跳转。
    return GestureDetector(
      onTap: () => appRouter.push(AppRoutes.play),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: topRadius,
          boxShadow: const [
            BoxShadow(
              blurRadius: 5,
              color: Color(0x1EFFFFFF),
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: BlurView(
          radius: topRadius,
          child: Container(
            padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(top: BorderSide(color: Color(0xA6FFFFFF))),
            ),
            child: Row(
              spacing: 15,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: music.cover,
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
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
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          music.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 喜欢按钮：切换本地收藏，贴图自带颜色，已收藏实心、未收藏空心。
                IconButton(
                  onPressed: () =>
                      ref.read(favoritesProvider.notifier).toggle(music.source),
                  icon: Image.asset(
                    isFavorite ? _favoriteFilledAsset : _favoriteOutlineAsset,
                    width: AppSizes.icon,
                    height: AppSizes.icon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
