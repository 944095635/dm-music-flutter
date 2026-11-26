import 'package:material_ui/material_ui.dart';

import 'package:dm_music/app/routes/app_router.dart';
import 'package:dm_music/app/theme/app_theme.dart';

/// 应用根组件。使用 go_router 的全局路由配置。
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DMusic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
