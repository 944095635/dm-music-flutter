import 'package:shared_preferences/shared_preferences.dart';
import 'package:dm_music/value/cache_keys.dart';

class CacheHelper {
  /// 获取设置项(字符串)
  static Future<String?> getString(CacheKeys key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key.name);
  }

  /// 设置设置项(字符串)
  static Future setString(CacheKeys key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key.name, value);
  }

  /// 获取设置项(布尔值)
  static Future<bool?> getBool(CacheKeys key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key.name);
  }

  /// 设置设置项(布尔值)
  static Future setBool(CacheKeys key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key.name, value);
  }
}
