import 'dart:io';

import 'package:dm_music/core/network/user_agent.dart';

/// 给所有 dart:io HttpClient 请求统一注入浏览器 UA。
///
/// 解决网易云图床对无 UA 返回 403 的问题；图片与接口请求都走这里，
/// 不需要在各个调用点单独传 header。只用于 native 端，web 见 stub 文件。
class _UserAgentHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..userAgent = appUserAgent;
  }
}

/// 初始化全局 HTTP 覆盖。必须在发起任何网络请求前调用。
void installHttpOverrides() {
  HttpOverrides.global = _UserAgentHttpOverrides();
}
