import 'package:http/http.dart' as http;

/// 网络帮助类
class NetworkHelper {
  /// 解决IOS首次安装没有网络的问题
  static Future init() async {
    return http
        .get(Uri.parse("http://dmskin.com/"))
        .timeout(Duration(seconds: 15));
  }
}
