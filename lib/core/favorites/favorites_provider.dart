import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dm_music/core/models/music.dart';

/// SharedPreferences 实例，全应用共享一个，避免重复 open。
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// 喜欢歌曲列表的本地缓存。
///
/// 唯一标识用 [Music.id]（稳定 id）：歌名可能重复，动态播放地址会失效，
/// id 才是跨请求不变的标识。空 id 不参与收藏，避免多首无地址曲目共用同一收藏位。
/// 状态为收藏集合；读取、切换都走这里，页面只 watch 本 provider。
final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
      FavoritesNotifier.new,
    );

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  /// 本地存储键。
  ///
  /// 沿用旧键名：首页曲目 id 即其 source（静态地址），老数据可无缝复用；
  /// 歌单老数据存的是已失效的动态 URL，天然匹配不上新 id，无需额外迁移。
  static const String _storageKey = 'favorite_sources';

  @override
  Future<Set<String>> build() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    return prefs.getStringList(_storageKey)?.toSet() ?? <String>{};
  }

  /// 该 id 是否已收藏。加载中/出错/空 id 时按未收藏处理。
  /// Riverpod 3 的 AsyncValue.value 可空，无值时即未加载完成。
  bool contains(String id) {
    if (id.isEmpty) return false;
    return state.value?.contains(id) ?? false;
  }

  /// 切换收藏状态并立即落盘。乐观更新：先改状态，再写本地存储。
  /// 空 id 直接忽略，防止所有无地址曲目串到同一个收藏位。
  Future<void> toggle(String id) async {
    if (id.isEmpty) return;
    final current = state.value ?? <String>{};
    final next = <String>{...current};
    if (!next.add(id)) next.remove(id);
    state = AsyncData(next);

    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setStringList(_storageKey, next.toList());
  }
}
