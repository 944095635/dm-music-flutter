import 'dart:convert';
import 'package:dm_music/models/music_source.dart';
import 'package:dm_music/values/cache_keys.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 缓存助手
class CacheHelper {
  /// 获取缓存的播放源列表
  static Future<List<MusicSource>?> getSourceList({
    SharedPreferences? prefs,
  }) async {
    prefs ??= await SharedPreferences.getInstance();
    String? sourceListJson = prefs.getString(
      CacheKeys.sourceList.toString(),
    );
    if (sourceListJson?.isNotEmpty == true) {
      List<dynamic> sourceListMap = json.decode(sourceListJson!);
      List<MusicSource> sourceList = List.empty(growable: true);
      for (var sourceMap in sourceListMap) {
        sourceList.add(MusicSource.fromJson(sourceMap));
      }
      return sourceList;
    }
    return null;
  }

  /// 设置缓存的播放源列表
  static Future<bool> setSourceList(List<MusicSource> sourceList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String sourceListJson = json.encode(sourceList);
      return prefs.setString(CacheKeys.sourceList.toString(), sourceListJson);
    } catch (e) {
      return false;
    }
  }

  /// 设置当前的数据源
  static Future<bool> setSource(String sourceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(CacheKeys.sourceId.toString(), sourceId);
  }

  /// 获取当前数据源
  static Future<MusicSource?> getSource() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sourceId = prefs.getString(CacheKeys.sourceId.toString());
    if (sourceId == MusicSourceType.dmusic.id) {
      // 官方数据源
      return MusicSource(
        id: MusicSourceType.dmusic.id,
        type: MusicSourceType.dmusic,
      );
    }
    List<dynamic>? sourceList = await getSourceList(prefs: prefs);
    if (sourceId != null && sourceList != null) {
      return sourceList.firstWhereOrNull((p) => p.id == sourceId);
    }
    return null;
  }
}
