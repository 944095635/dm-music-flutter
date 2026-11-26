import 'dart:math' show max;

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

/// iOS 边缘侧滑手势的识别宽度（逻辑像素）。
const double _kBackGestureWidth = 20.0;

/// 判定为快速滑动的最小速度（屏宽 / 秒）。
const double _kMinFlingVelocity = 1.0;

/// 松手后完成剩余动画的时长。
const Duration _kDroppedSwipePageAnimationDuration = Duration(milliseconds: 350);

/// 渐显进入、支持 iOS 边缘侧滑跟手返回的 Page。
///
/// 侧滑手势与淡出动画共用 Route 的 AnimationController：手势把 controller
/// 往回拨，透明度随之下降，松手超过阈值才真正 pop，否则回弹。
/// 这是 Flutter 原生 CupertinoPageRoute 手势机制的解耦版本。
///
/// 用法（go_router 的 pageBuilder）：
/// ```dart
/// pageBuilder: (context, state) => FadePopPage(
///   key: state.pageKey,
///   child: const PlayView(),
/// ),
/// ```
class FadePopPage<T> extends Page<T> {
  const FadePopPage({
    required this.child,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.maintainState = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;
  final bool maintainState;

  @override
  Route<T> createRoute(BuildContext context) => _FadePopRoute<T>(this);
}

class _FadePopRoute<T> extends PageRoute<T> {
  _FadePopRoute(FadePopPage<T> page) : super(settings: page);

  FadePopPage<T> get _page => settings as FadePopPage<T>;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get opaque => true;

  @override
  bool get maintainState => _page.maintainState;

  @override
  Duration get transitionDuration => _page.transitionDuration;

  @override
  Duration get reverseTransitionDuration => _page.reverseTransitionDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: _page.child,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 跟手阶段用线性动画，保证透明度与手指位移一致；普通进入用缓动。
    final Animation<double> opacity = popGestureInProgress
        ? animation
        : CurvedAnimation(parent: animation, curve: Curves.easeOut);
    return FadeTransition(
      opacity: opacity,
      child: _BackGestureDetector<T>(
        enabledCallback: () => popGestureEnabled,
        onStartPopGesture: () => _BackGestureController<T>(
          navigator: navigator!,
          controller: controller!,
          getIsActive: () => isActive,
          getIsCurrent: () => isCurrent,
        ),
        child: child,
      ),
    );
  }
}

/// 屏幕左边缘的返回手势识别器。
///
/// 移植自 Flutter SDK 的 `_CupertinoBackGestureDetector`，改为项目内私有实现，
/// 以便脱离 CupertinoPageRoute 的横向滑动动画单独使用。
class _BackGestureDetector<T> extends StatefulWidget {
  const _BackGestureDetector({
    required this.enabledCallback,
    required this.onStartPopGesture,
    required this.child,
  });

  final Widget child;
  final ValueGetter<bool> enabledCallback;
  final ValueGetter<_BackGestureController<T>> onStartPopGesture;

  @override
  State<_BackGestureDetector<T>> createState() => _BackGestureDetectorState<T>();
}

class _BackGestureDetectorState<T> extends State<_BackGestureDetector<T>> {
  _BackGestureController<T>? _backGestureController;
  late HorizontalDragGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    // 拖拽中被销毁时，补一次 didStopUserGesture，避免 Route 卡在手势态。
    if (_backGestureController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_backGestureController?.navigator.mounted ?? false) {
          _backGestureController?.navigator.didStopUserGesture();
        }
        _backGestureController = null;
      });
    }
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    assert(mounted);
    assert(_backGestureController == null);
    _backGestureController = widget.onStartPopGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted);
    assert(_backGestureController != null);
    _backGestureController!.dragUpdate(
      _convertToLogical(details.primaryDelta! / context.size!.width),
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(mounted);
    assert(_backGestureController != null);
    _backGestureController!.dragEnd(
      _convertToLogical(details.velocity.pixelsPerSecond.dx / context.size!.width),
    );
    _backGestureController = null;
  }

  void _handleDragCancel() {
    assert(mounted);
    _backGestureController?.dragEnd(0.0);
    _backGestureController = null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.enabledCallback()) {
      _recognizer.addPointer(event);
    }
  }

  double _convertToLogical(double value) {
    return switch (Directionality.of(context)) {
      TextDirection.rtl => -value,
      TextDirection.ltr => value,
    };
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    // 刘海屏左侧手势区域需扩到安全区宽度。
    final double dragAreaWidth = switch (Directionality.of(context)) {
      TextDirection.rtl => MediaQuery.paddingOf(context).right,
      TextDirection.ltr => MediaQuery.paddingOf(context).left,
    };
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        widget.child,
        PositionedDirectional(
          start: 0.0,
          width: max(dragAreaWidth, _kBackGestureWidth),
          top: 0.0,
          bottom: 0.0,
          child: Listener(
            onPointerDown: _handlePointerDown,
            behavior: HitTestBehavior.translucent,
          ),
        ),
      ],
    );
  }
}

/// 返回手势控制器：直接倒放 Route 的 AnimationController。
///
/// 移植自 Flutter SDK 的 `_CupertinoBackGestureController`。
/// 0.0 表示页面已退出，1.0 表示页面在最上层。
class _BackGestureController<T> {
  _BackGestureController({
    required this.navigator,
    required this.controller,
    required this.getIsActive,
    required this.getIsCurrent,
  }) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;
  final ValueGetter<bool> getIsActive;
  final ValueGetter<bool> getIsCurrent;

  /// 手指拖动：delta 为本次位移占屏宽的比例。
  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  /// 手指松开：按速度与当前进度决定 pop 还是回弹。
  void dragEnd(double velocity) {
    const Curve animationCurve = Curves.fastEaseInToSlowEaseOut;
    final bool isCurrent = getIsCurrent();
    final bool animateForward;

    if (!isCurrent) {
      // 页面已被程序性导航离开时，按是否在栈内决定方向，忽略手势。
      animateForward = getIsActive();
    } else if (velocity.abs() >= _kMinFlingVelocity) {
      animateForward = velocity <= 0;
    } else {
      animateForward = controller.value > 0.5;
    }

    if (animateForward) {
      controller.animateTo(
        1.0,
        duration: _kDroppedSwipePageAnimationDuration,
        curve: animationCurve,
      );
    } else {
      if (isCurrent) {
        navigator.pop();
      }
      if (controller.isAnimating) {
        controller.animateBack(
          0.0,
          duration: _kDroppedSwipePageAnimationDuration,
          curve: animationCurve,
        );
      }
    }

    if (controller.isAnimating) {
      // 动画期间保持 userGestureInProgress，避免转场曲线中途跳变。
      late final AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (AnimationStatus status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }
}
