import 'dart:convert';
import 'dart:io';

import 'package:dm_music/apis/cloud_music_api/utils/nested_crypto_utils.dart';

class Request {
  /// 浏览器 UA
  static List<String> userAgentList = [
    // iOS 13.5.1 14.0 beta with safari
    "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.",
    // iOS with qq micromsg
    "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5_1 like Mac OS X) AppleWebKit/602.1.50 (KHTML like Gecko) Mobile/14A456 QQ/6.5.7.408 V1_IPH_SQ_6.5.7_1_APP_A Pixel/750 Core/UIWebView NetType/4G Mem/103",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/7.0.15(0x17000f27) NetType/WIFI Language/zh",
    // Android -> Huawei Xiaomi
    "Mozilla/5.0 (Linux; Android 9; PCT-AL10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.64 HuaweiBrowser/10.0.3.311 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; U; Android 9; zh-cn; Redmi Note 8 Build/PKQ1.190616.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/71.0.3578.141 Mobile Safari/537.36 XiaoMi/MiuiBrowser/12.5.22",
    // Android + qq micromsg
    "Mozilla/5.0 (Linux; Android 10; YAL-AL00 Build/HUAWEIYAL-AL00; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/78.0.3904.62 XWEB/2581 MMWEBSDK/200801 Mobile Safari/537.36 MMWEBID/3027 MicroMessenger/7.0.18.1740(0x27001235) Process/toolsmp WeChat/arm64 NetType/WIFI Language/zh_CN ABI/arm64",
    "Mozilla/5.0 (Linux; U; Android 8.1.0; zh-cn; BKK-AL10 Build/HONORBKK-AL10) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/66.0.3359.126 MQQBrowser/10.6 Mobile Safari/537.36",
    // macOS 10.15.6  Firefox / Chrome / Safari
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:80.0) Gecko/20100101 Firefox/80.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.30 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.2 Safari/605.1.15",
    // Windows 10 Firefox / Chrome / Edge
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:80.0) Gecko/20100101 Firefox/80.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.30 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/13.10586",
  ];

  /// 发起请求
  static Future<Map?> createRequest({
    required String method,
    required String host,
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      // 跨域Token
      //data["csrf_token"] = "";
      if (true) {
        // 加密数据
        data = NestedCryptoUtils().weapi(data);
        RegExp exp = RegExp(r"\w*api");
        path = path.replaceAll(exp, "weapi");
      }

      Uri uri = Uri(
        host: host,
        path: path,
        queryParameters: data,
        scheme: "https",
      );
      HttpClient client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);
      client.idleTimeout = const Duration(seconds: 15);
      HttpClientRequest request = await client.postUrl(uri);
      request.headers.set(
        "User-Agent",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 Edg/116.0.1938.69",
      );

      if (uri.host.toLowerCase().contains("music.163.com")) {
        request.headers.set("Referer", "https://music.163.com");
      }
      // 添加POST数据
      if (method.toLowerCase() == "post") {
        request.headers.set(
          "Content-Type",
          "application/x-www-form-urlencoded",
        );
        //request.headers.add("Cookie", "");
        request.add(utf8.encode(json.encode(data)));
      }
      HttpClientResponse response1 = await request.close();
      String responseBody = await response1.transform(utf8.decoder).join();
      client.close();
      return json.decode(responseBody);
    } catch (e) {
      //debugPrint(e.toString());
    }
    return null;
  }
}
