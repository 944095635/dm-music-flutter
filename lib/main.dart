import 'package:dm_music_flutter/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DM Music',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        cardColor: const Color.fromRGBO(255, 255, 255, 0.5),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        shadowColor: const Color.fromARGB(31, 163, 163, 163),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          foregroundColor: Color(0xFF333333),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF333333),
          ),
          bodySmall: TextStyle(
            fontSize: 11,
            color: Color(0xFF666666),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF9570FF),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color.fromRGBO(0, 0, 0, 0.5),
        shadowColor: Colors.white10,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          foregroundColor: Color(0xFFEEEEEE),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.black,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
          bodySmall: TextStyle(
            fontSize: 11,
            color: Color(0xFFEEEEEE),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF9570FF),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
