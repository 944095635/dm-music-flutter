import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:dm_music/app/routes/app_routes.dart';
import 'package:dm_music/app/routes/fade_pop_page.dart';
import 'package:dm_music/modules/home/views/home_view.dart';
import 'package:dm_music/modules/play/views/play_view.dart';
import 'package:dm_music/modules/splash/views/splash_view.dart';

/// 全局路由实例。
///
/// 任意位置（含非 Widget 的 Provider / Service）均可无 context 跳转：
///   appRouter.go(AppRoutes.home);   // 覆盖当前栈，目标页成为新的栈底
///   appRouter.push('/detail');      // 压入栈顶，可返回上一页
/// 在 Widget 内仍可用 context.go() / context.push()。
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: AppRoutes.home,
      // 覆盖跳转时以渐显动画进入首页。
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomeView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: AppRoutes.play,
      // 渐显进入；iOS 左侧边缘可跟手侧滑返回，松手淡出或回弹。
      pageBuilder: (context, state) => FadePopPage(
        key: state.pageKey,
        child: const PlayView(),
      ),
    ),
  ],
);
