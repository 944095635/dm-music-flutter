import 'package:dm_music/pages/home/view.dart';
import 'package:dm_music/services/play_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() {
  Get.put(PlayService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: _getLightTheme(),
      darkTheme: _getDarkTheme(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }

  /// 白色主题
  ThemeData _getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
        ),
      ),
      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        // 主色调
        primary: Colors.white,
        //主色调 - 反转
        inversePrimary: Colors.white,
        // 文字颜色
        onSurface: Colors.black,
        // 文字颜色 - 反转
        onInverseSurface: Colors.white,
        // 表面颜色
        surface: Colors.white,
        // 表面颜色 - 反转
        inverseSurface: Colors.black,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
        ),
      ),
      //进度条风格
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.black26,
        linearTrackColor: Colors.black12,
      ),
      drawerTheme: const DrawerThemeData(
        width: 260,
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        // 手柄颜色
        dragHandleColor: Colors.grey,
        backgroundColor: Colors.black,
        modalBarrierColor: Colors.transparent,
        modalBackgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
      ),
      switchTheme: const SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
        thumbColor: WidgetStatePropertyAll(Colors.white38),
        trackColor: WidgetStatePropertyAll(Colors.white10),
        // inactiveThumbColor: Colors.white30,
        // inactiveTrackColor: Colors.white38,
        // activeColor: Colors.white,
        // activeTrackColor: Colors.white30,
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 2.5,
        thumbColor: Colors.white,
        activeTrackColor: Colors.black87,
        inactiveTrackColor: Colors.black12,
        overlayColor: Colors.black12,
        overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
      ),
    );
  }

  /// 黑色主题
  ThemeData _getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        // 主色调
        primary: Colors.black,
        //主色调 - 反转
        inversePrimary: Colors.black,
        // 文字颜色
        onSurface: Colors.white,
        // 文字颜色 - 反转
        onInverseSurface: Colors.black,
        // 表面颜色
        surface: Colors.black,
        // 表面颜色 - 反转
        inverseSurface: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
        ),
      ),
      //进度条风格
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white54,
        linearTrackColor: Colors.white24,
      ),
      drawerTheme: const DrawerThemeData(
        width: 260,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        // 手柄颜色
        dragHandleColor: Colors.grey,
        backgroundColor: Colors.black,
        modalBarrierColor: Colors.transparent,
        modalBackgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
      ),
      switchTheme: const SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
        thumbColor: WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStatePropertyAll(Colors.white38),
        // inactiveThumbColor: Colors.white30,
        // inactiveTrackColor: Colors.white38,
        // activeColor: Colors.white,
        // activeTrackColor: Colors.white30,
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 2.5,
        thumbColor: Colors.white,
        activeTrackColor: Colors.white54,
        inactiveTrackColor: Colors.white12,
        overlayColor: Colors.white12,
        overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
      ),
    );
  }
}
