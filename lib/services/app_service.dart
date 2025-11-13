import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppService extends GetxService {
  bool isLogin = false;
  String? _token;
  String get token => _token ?? "";

  String? _userName;
  String get userName => _userName ?? "";

  String? _name;
  String get name => _name ?? "";

  Future init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
    _name = prefs.getString("name");
    _userName = prefs.getString("username");
    if (token?.isNotEmpty == true) {
      isLogin = true;
    }
  }
}
