import 'dart:io';

class PlatformUtils {
  /// 是否桌面平台
  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  /// 是否桌面平台
  static bool get isPhone => Platform.isAndroid || Platform.isIOS;
}
