import 'package:material_ui/material_ui.dart';

import 'package:dm_music/app/routes/app_router.dart';
import 'package:dm_music/app/theme/app_theme.dart';
import 'package:dm_music/modules/splash/views/splash_view.dart';

/// 应用根组件。用全局 navigatorKey + home 启动，跳转统一走 [AppRouter]。
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DMusic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      navigatorKey: AppRouter.navigatorKey,
      home: const SplashView(),
    );
  }
}
