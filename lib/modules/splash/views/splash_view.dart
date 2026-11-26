import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'package:dm_music/app/routes/app_router.dart';
import 'package:dm_music/modules/home/views/home_view.dart';

/// 启动页：展示 Logo，停留 2 秒后跳转首页。
///
/// 跳转用 [AppRouter].off() 替换当前页，启动页不留在回退栈中。
/// 首页以渐显过渡呈现。
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
    // off() 替换当前页（非 push），启动页不会留在回退栈中；渐显进入首页。
    AppRouter.off(const HomeView(), fade: true);
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
