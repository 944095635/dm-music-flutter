import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

  static const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  static String? _salt;

  static String? _token;

  /// 创建随机“盐”
  static String createSalt() {
    if (_salt != null) {
      return _salt!;
    }
    final rnd = Random.secure();
    final length = 6 + rnd.nextInt(6); // 6..11 chars
    _salt = List.generate(
      length,
      (_) => chars[rnd.nextInt(chars.length)],
    ).join();
    return _salt!;
  }

  static String createToken(String password, String s) {
    if (_token != null) {
      return _token!;
    }
    _token = md5.convert(utf8.encode(password + s)).toString();
    return _token!;
  }

  /// 创建Url对象
  static Uri _createUrl(
    NavidromeData data,
    String path, [
    Map<String, dynamic>? parameters,
    bool userApi = false,
  ]) {
    // String s = createSalt();
    // String t = createToken(data.password, s);
    Map<String, dynamic>? queryParameters;
    if (!userApi) {
      queryParameters = {
        "t": data.subsonicToken,
        "s": data.subsonicSalt,
        "v": ver,
        "f": "json",
        "u": data.user,
        "c": Strings.appName,
      };
      if (parameters != null) {
        queryParameters.addAll(parameters);
      }
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
    bool useApi = false,
  ]) async {
    HttpResult httpResult = HttpResult();
    try {
      var url = _createUrl(data, path, parameters, useApi);
      Map<String, String>? headers;
      if (useApi && data.token != null) {
        headers = {"x-nd-authorization": "Bearer ${data.token!}"};
      }
      var result = await http.get(url, headers: headers);
      debugPrint("url:$url");
      if (result.statusCode == 200) {
        String jsonBody = result.body;
        var map = json.decode(jsonBody);
        if (useApi) {
          if (map != null) {
            httpResult.status = true;
            httpResult.data = map;
          }
        } else {
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
      }
    } catch (e) {
      //debugPrint(e.toString());
      httpResult.status = false;
      httpResult.msg = "网络异常";
    }
    return httpResult;
  }

  /// 通用Post函数
  static Future<HttpResult> _post(
    NavidromeData data,
    String path, [
    Map<String, String>? parameters,
    bool useApi = false,
  ]) async {
    HttpResult httpResult = HttpResult();
    try {
      var url = _createUrl(data, path, parameters, useApi);
      Map<String, String> headers = {"content-type": "application/json"};
      if (useApi && data.token != null) {
        headers.addAll({"x-nd-authorization": data.token!});
      }
      var result = await http.post(
        url,
        headers: headers,
        body: json.encode(parameters),
      );
      debugPrint("url:$url");
      if (result.statusCode == 200) {
        String jsonBody = result.body;
        var map = json.decode(jsonBody);
        if (useApi) {
          if (map != null) {
            httpResult.status = true;
            httpResult.data = map;
          }
        } else {
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
      }
    } catch (e) {
      //debugPrint(e.toString());
      httpResult.status = false;
      httpResult.msg = "网络异常";
    }
    return httpResult;
  }

  /// 获取播放源
  static Future<String> getStream(
    NavidromeData data,
    String id,
    //int size,
  ) async {
    Uri url = _createUrl(data, "/rest/stream", {
      "id": id,
    });
    return url.toString();
  }

  /// 获取封面图
  static Future<String> getCoverUrl(
    NavidromeData data,
    String coverArt,
    //int size,
  ) async {
    Uri url = _createUrl(data, "/rest/getCoverArt", {
      "id": coverArt,
      //"size": size.toString(),
    });
    return url.toString();
  }

  /// ping服务器
  static Future<HttpResult> ping(NavidromeData data) async {
    return _get(data, '/rest/ping.view');
  }

  /// 获取专辑列表
  static Future<HttpResult> getAlbumList({
    required NavidromeData data,
    required String type, // 必传 random，newest， highest，frequent，recent
    String? name,
  }) async {
    return _get(data, '/rest/getAlbumList', {
      "type": type,
      "size": "500",
      "alphabeticalByName": name,
    });
  }

  /// 获取专辑
  static Future<HttpResult> getAlbum(
    NavidromeData data, {
    required String id,
  }) async {
    return _get(data, '/rest/getAlbum', {"id": id});
  }

  /// 获取歌曲
  static Future<HttpResult> getSong({
    required NavidromeData data,
    required String id,
  }) async {
    return _get(data, '/rest/getSong', {"id": id});
  }

  /// 获取歌曲
  static Future<HttpResult> getSong1({
    required NavidromeData data,
    required String id,
  }) async {
    //http://183.66.27.24:4533/api/song?id=8ae63f12d122923e5fdc0cfb50ac17e2
    return _get(data, '/api/song/$id', {}, true);
  }

  /// 获取歌词
  static Future<HttpResult> getLyrics(
    NavidromeData data, {
    String? title,
    String? artist,
  }) async {
    return _get(data, '/rest/getLyrics', {"title": title, "artist": artist});
  }

  /// api 接口登录
  static Future<HttpResult> login(
    NavidromeData data,
    String username,
    String password,
  ) {
    return _post(data, '/auth/login', {
      "username": username,
      "password": password,
    }, true);
  }
}
