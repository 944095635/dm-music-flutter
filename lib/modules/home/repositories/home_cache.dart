import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dm_music/core/favorites/favorites_provider.dart'
    show sharedPreferencesProvider;

/// 首页推荐列表的本地缓存。
///
/// 请求成功时写入，网络失败时读取上一次成功的数据兜底。
/// 各组列表各存一个键，互不影响；通过 [fromJson]/[toJson] 支持不同类型。
final homeCacheProvider = FutureProvider<HomeCache>((ref) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  return HomeCache(prefs);
});

class HomeCache {
  HomeCache(this._prefs);

  final SharedPreferences _prefs;

  /// 新歌推荐的存储键。
  static const String newReleasesKey = 'home_new_releases_cache';

  /// 流行推荐的存储键。
  static const String popularKey = 'home_popular_cache';

  /// 网易云推荐歌单的存储键。
  static const String playlistsKey = 'home_playlists_cache';

  /// 读取缓存；无缓存或数据损坏时返回 null。
  List<T>? read<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(growable: false);
    } catch (_) {
      // 缓存内容损坏时按无缓存处理，让上层正常展示错误视图。
      return null;
    }
  }

  /// 写入缓存。
  Future<void> write<T>(
    String key,
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) {
    final raw = jsonEncode(items.map(toJson).toList());
    return _prefs.setString(key, raw);
  }
}
