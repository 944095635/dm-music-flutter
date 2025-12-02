import 'package:http/http.dart' as http;

class NetworkHelper {
  /// 解决IOS首次安装没有网络的问题
  static Future init() async {
    return http.get(Uri.parse("https://github.com/944095635"));
  }
}
