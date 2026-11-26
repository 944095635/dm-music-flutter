import 'package:flutter/services.dart';

import 'package:material_ui/material_ui.dart';

/// 全局主题。颜色/字号/间距集中在这里，页面不写死样式值。
abstract final class AppTheme {
  /// 全局返回按钮统一 iOS 风格 chevron（‹），不随运行平台切换。
  ///
  /// 返回按钮图标不归 AppBarTheme 管：AppBar 的默认 leading 是 BackButton，
  /// 其 BackButtonIcon 优先读这里的 backButtonIconBuilder，
  /// 未设置时才按 Theme.platform 区分 Android / iOS 图标。
  static final ActionIconThemeData _actionIconTheme = ActionIconThemeData(
    backButtonIconBuilder: (_) => const Icon(Icons.arrow_back_ios_new_rounded),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    actionIconTheme: _actionIconTheme,
    colorScheme: ColorScheme.light(
      primary: Colors.black,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    actionIconTheme: _actionIconTheme,
    colorScheme: ColorScheme.dark(
      primary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    scaffoldBackgroundColor: Colors.black,
  );
}
