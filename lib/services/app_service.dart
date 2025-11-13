import 'package:dm_music/values/cache_keys.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App 服务
class AppService extends GetxService {
  bool isLogin = false;

  String? _token;
  String get token => _token ?? "";

  String? _userName;
  String get userName => _userName ?? "";

  String? _name;
  String get name => _name ?? "";

  /// 是否已经初始化
  bool isInit = false;

  Future init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
    _name = prefs.getString("name");
    _userName = prefs.getString("username");
    if (_token?.isNotEmpty == true) {
      isLogin = true;
    }

    // 读取是否初始化
    isInit = prefs.getBool(CacheKeys.init.toString()) ?? false;
  }

  /// 设置初始化
  Future inited() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // 设置初始化
    prefs.setBool(CacheKeys.init.toString(), true);
  }
}
