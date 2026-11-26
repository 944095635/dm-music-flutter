import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'package:dm_music/app/routes/app_routes.dart';
import 'package:dm_music/app/routes/app_router.dart';

/// 启动页：展示 Logo，停留 2 秒后跳转首页。
///
/// 跳转用全局 [appRouter].go() 覆盖路由栈，启动页不会留在回退栈中。
/// 首页路由配有渐显过渡，跳转时平滑呈现。
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  static const Duration _navigateDelay = Duration(seconds: 2);

  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();
    _navigateTimer = Timer(_navigateDelay, _navigateToHome);
  }

  @override
  void dispose() {
    _navigateTimer?.cancel();
    super.dispose();
  }

  void _navigateToHome() {
    if (!mounted) return;
    // go() 覆盖当前栈（非 push），启动页不会留在回退栈中。
    appRouter.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 200,
          cacheWidth: 400,
        ),
      ),
    );
  }
}
