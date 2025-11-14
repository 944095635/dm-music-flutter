import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:dm_music/models/http_result.dart';
import 'package:dm_music/models/login_data/navidrome_data.dart';
import 'package:dm_music/values/strings.dart';

class NavidromeApi {
  // 参数u ：用户名(必传)
  // 参数s ：用于计算密码哈希的随机字符串
  // 参数t ：计算出的认证令牌为 md5(密码 + 盐)
  // 参数v ：客户端协议版本 亚音速版本 6.1.4 + REST API 版本 1.16.1
  // 参数c ：客户端名称
  // 参数f ：返回结构 "xml" 或者 "json"

  static const String ver = "1.16.1";

  /// 创建随机“盐”
  static String _createSalt() {
    final rnd = Random.secure();
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final length = 6 + rnd.nextInt(6); // 6..11 chars
    return List.generate(
      length,
      (_) => chars[rnd.nextInt(chars.length)],
    ).join();
  }

  /// 创建Url对象
  static Uri _createUrl(
    NavidromeData data,
    String path, [
    Map<String, dynamic>? parameters,
  ]) {
    String s = _createSalt();
    String t = md5.convert(utf8.encode(data.password + s)).toString();
    Map<String, dynamic> queryParameters = {
      "t": t,
      "s": s,
      "v": ver,
      "f": "json",
      "u": data.user,
      "c": Strings.appName,
    };
    if (parameters != null) {
      queryParameters.addAll(parameters);
    }
    return Uri.http(
      data.server,
      path,
      queryParameters,
    );
  }

  /// 通用Get函数
  static Future<HttpResult> _get(
    NavidromeData data,
    String path, [
    Map<String, dynamic>? parameters,
  ]) async {
    HttpResult httpResult = HttpResult();
    try {
      var url = _createUrl(data, path, parameters);
      var result = await http.get(url);
      if (result.statusCode == 200) {
        String jsonBody = result.body;
        var map = json.decode(jsonBody);
        Map subResponse = map["subsonic-response"];
        String status = subResponse["status"];
        //debugPrint(status);
        httpResult.status = status == "ok";
        if (httpResult.status) {
          httpResult.data = subResponse;
        } else {
          Map error = subResponse["error"];
          // int errorCode = error["code"];
          String errorMsg = error["message"];
          httpResult.msg = errorMsg;
        }
      }
    } catch (e) {
      //debugPrint(e.toString());
      httpResult.status = false;
      httpResult.msg = "网络异常";
    }
    return httpResult;
  }

  /// ping服务器
  static Future<HttpResult> ping(NavidromeData data) async {
    return _get(data, '/rest/ping.view');
  }

  /// 获取专辑
  static Future<HttpResult> getAlbumList({
    required NavidromeData data,
    required String type, // 必传 random，newest， highest，frequent，recent
  }) async {
    return _get(data, '/rest/getAlbumList', {"type": type});
  }
}
