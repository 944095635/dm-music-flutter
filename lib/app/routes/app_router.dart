import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

/// 全局路由服务：无需 context 即可跳转。
///
/// 直接用原生 Navigator + Route，绕开 go_router 的 Page 抽象，
/// 这样可以精确控制每个跳转用哪种 Route：
/// - CupertinoPageRoute：iOS 自带左侧边缘侧滑返回（默认）；
/// - MaterialPageRoute：Android 风格转场；
/// - fade：渐显转场（注意此方式不带 iOS 侧滑手势）。
class AppRouter {
  /// 全局 NavigatorKey，挂在 MaterialApp.navigatorKey 上。
  static final navigatorKey = GlobalKey<NavigatorState>();

  AppRouter._();

  static NavigatorState? get _navigator => navigatorKey.currentState;

  /// 压入新页面（可返回）。
  static Future<T?> to<T>(
    Widget page, {
    bool fade = false,
    bool useCupertino = true,
    String? routeName,
  }) {
    final route = _buildRoute<T>(
      page,
      fade: fade,
      useCupertino: useCupertino,
      routeName: routeName,
    );
    return _navigator?.push(route) ?? Future.value();
  }

  /// 替换当前页面（启动页 → 首页，回退栈不留启动页）。
  static Future<T?> off<T>(
    Widget page, {
    bool fade = false,
    bool useCupertino = true,
    String? routeName,
  }) {
    final route = _buildRoute<T>(
      page,
      fade: fade,
      useCupertino: useCupertino,
      routeName: routeName,
    );
    return _navigator?.pushReplacement(route) ?? Future.value();
  }

  /// 清除所有页面后压入新页面。
  static Future<T?> offAll<T>(
    Widget page, {
    bool fade = false,
    bool useCupertino = true,
    String? routeName,
  }) {
    final route = _buildRoute<T>(
      page,
      fade: fade,
      useCupertino: useCupertino,
      routeName: routeName,
    );
    return _navigator?.pushAndRemoveUntil(route, (_) => false) ?? Future.value();
  }

  /// 返回上一页。
  static void pop<T>([T? result]) => _navigator?.pop(result);

  /// 返回到指定名称的页面。
  static void popUntil(String routeName) =>
      _navigator?.popUntil(ModalRoute.withName(routeName));

  /// 获取当前上下文。
  static BuildContext? get context => navigatorKey.currentContext;

  /// 统一构建 Route。fade 优先：为 true 时忽略 useCupertino。
  static PageRoute<T> _buildRoute<T>(
    Widget page, {
    required bool fade,
    required bool useCupertino,
    String? routeName,
  }) {
    if (fade) return _buildFadeRoute<T>(page, routeName: routeName);
    return _buildPageRoute<T>(page, useCupertino, routeName: routeName);
  }

  /// 渐显转场（无 iOS 侧滑手势）。
  static PageRoute<T> _buildFadeRoute<T>(Widget page, {String? routeName}) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: routeName),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(
            Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeInOut),
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// 标准页面转场：Cupertino（带侧滑）或 Material。
  static PageRoute<T> _buildPageRoute<T>(
    Widget page,
    bool useCupertino, {
    String? routeName,
  }) {
    final settings = RouteSettings(name: routeName);
    if (useCupertino) {
      return CupertinoPageRoute<T>(settings: settings, builder: (_) => page);
    }
    return MaterialPageRoute<T>(settings: settings, builder: (_) => page);
  }
}
