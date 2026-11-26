import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 实例，全应用共享一个，避免重复 open。
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// 喜欢歌曲列表的本地缓存。
///
/// 唯一标识用歌曲的 source（音频 URL）：歌名可能重复，source 天然唯一稳定。
/// 状态为收藏集合；读取、切换都走这里，页面只 watch 本 provider。
final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
      FavoritesNotifier.new,
    );

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  /// 本地存储键。
  static const String _storageKey = 'favorite_sources';

  @override
  Future<Set<String>> build() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    return prefs.getStringList(_storageKey)?.toSet() ?? <String>{};
  }

  /// 该 source 是否已收藏。加载中/出错时按未收藏处理。
  /// Riverpod 3 的 AsyncValue.value 可空，无值时即未加载完成。
  bool contains(String source) => state.value?.contains(source) ?? false;

  /// 切换收藏状态并立即落盘。乐观更新：先改状态，再写本地存储。
  Future<void> toggle(String source) async {
    final current = state.value ?? <String>{};
    final next = <String>{...current};
    if (!next.add(source)) next.remove(source);
    state = AsyncData(next);

    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setStringList(_storageKey, next.toList());
  }
}
