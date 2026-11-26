import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:material_ui/material_ui.dart';

/// 播放进度滑块的轨道形态。
enum PlayerSliderType {
  /// 水平直线轨道，含激活段与未激活段。
  line,

  /// 向上拱起的贝塞尔曲线轨道，仅绘制渐变激活段。
  curve,
}

/// 播放进度滑块。
///
/// 进度由 [valueListenable] 驱动（取值 0~1）：外部进度变化只重绘画布，不重建组件树。
/// 拖动时内部拖动值优先，松手后交还外部进度。
/// 所有颜色、尺寸均通过构造参数传入并带默认值，不读取系统主题。
class PlayerSliderView extends StatefulWidget {
  const PlayerSliderView({
    super.key,
    required this.valueListenable,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.sliderType = PlayerSliderType.line,
    this.inactiveColor = const Color(0x4DFFFFFF),
    this.thumbColor = Colors.white,
    this.overlayColor = const Color(0x4FFFFFFF),
    this.curveColors = const [
      Color(0xFFB7EAFF),
      Color(0xFF7ED9FF),
      Color(0xFF0F7BAA),
    ],
    this.curveColorStops = const [0, 0.6, 1],
    this.bezier = 0,
    this.thumbRadius = 2,
    this.thumbActiveRadius = 4,
    this.curveStrokeScale = 1.5,
    this.overlayRadius = 12,
    this.height = 35,
  });

  /// 归一化进度源（0~1），变化时只触发画布重绘。
  final ValueListenable<double> valueListenable;

  /// 值变化时回调（0~1）。
  final ValueChanged<double> onChanged;

  /// 开始交互时回调（0~1）。
  final ValueChanged<double>? onChangeStart;

  /// 结束交互时回调（0~1）。
  final ValueChanged<double>? onChangeEnd;

  /// 轨道形态。
  final PlayerSliderType sliderType;

  /// 直线轨道未激活段底色。
  final Color inactiveColor;

  /// 滑块颜色。
  final Color thumbColor;

  /// 按下高亮颜色。
  final Color overlayColor;

  /// 轨道渐变色：曲线与直线模式共用。
  final List<Color> curveColors;

  /// 渐变色对应的位置，需与 [curveColors] 等长。
  final List<double> curveColorStops;

  /// 曲线拱起高度，0 表示与水平线重合。
  final double bezier;

  /// 滑块默认半径。
  final double thumbRadius;

  /// 按下时滑块半径。
  final double thumbActiveRadius;

  /// 轨道线宽相对滑块半径的倍数：默认 1.5，即线宽 3、按下过渡到 6。
  /// 曲线与直线模式共用，保证两种形态粗细一致。
  final double curveStrokeScale;

  /// 按下高亮半径。
  final double overlayRadius;

  /// 组件高度。CustomPaint 无固有尺寸，显式给高度才能在 Column 等
  /// 无界高度约束的父组件中正常布局并保持可点击区域。
  final double height;

  @override
  State<PlayerSliderView> createState() => _PlayerSliderViewState();
}

class _PlayerSliderViewState extends State<PlayerSliderView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  /// 画布实际读取的进度：外部进度与拖动值统一写到这里。
  late final ValueNotifier<double> _displayProgress = ValueNotifier(
    _clamp(widget.valueListenable.value),
  );

  bool _active = false;

  static double _clamp(double value) => value.clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    widget.valueListenable.addListener(_onExternalProgress);
  }

  @override
  void didUpdateWidget(covariant PlayerSliderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_onExternalProgress);
      widget.valueListenable.addListener(_onExternalProgress);
      if (!_active) {
        _displayProgress.value = _clamp(widget.valueListenable.value);
      }
    }
  }

  @override
  void dispose() {
    widget.valueListenable.removeListener(_onExternalProgress);
    _displayProgress.dispose();
    _pressController.dispose();
    super.dispose();
  }

  /// 外部进度变化时同步画布；拖动期间忽略，避免跟手被打断。
  void _onExternalProgress() {
    if (_active) return;
    _displayProgress.value = _clamp(widget.valueListenable.value);
  }

  double _valueFromDx(double dx, double width) =>
      width == 0 ? 0 : (dx / width).clamp(0.0, 1.0);

  void _start(double dx, double width) {
    if (_active) return;
    _active = true;
    final double value = _valueFromDx(dx, width);
    widget.onChangeStart?.call(value);
    _update(dx, width);
    _pressController.forward();
  }

  void _update(double dx, double width) {
    if (!_active) return;
    final double value = _valueFromDx(dx, width);
    if (value == _displayProgress.value) return;
    _displayProgress.value = value;
    widget.onChanged(value);
  }

  void _end() {
    if (!_active) return;
    widget.onChangeEnd?.call(_displayProgress.value);
    _active = false;
    _pressController.reverse();
    // 保留画布当前值，等外部进度（seek 结果）回写后再同步，避免松手瞬间跳回旧值。
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) =>
          _start(details.localPosition.dx, context.size?.width ?? 0),
      onTapUp: (_) => _end(),
      onTapCancel: _end,
      onHorizontalDragStart: (details) =>
          _start(details.localPosition.dx, context.size?.width ?? 0),
      onHorizontalDragUpdate: (details) =>
          _update(details.localPosition.dx, context.size?.width ?? 0),
      onHorizontalDragEnd: (_) => _end(),
      child: SizedBox(
        height: widget.height,
        child: CustomPaint(
          painter: _PlayerSliderPainter(
            progressListenable: _displayProgress,
            pressListenable: _pressController,
            sliderType: widget.sliderType,
            inactiveColor: widget.inactiveColor,
            thumbColor: widget.thumbColor,
            overlayColor: widget.overlayColor,
            curveColors: widget.curveColors,
            curveColorStops: widget.curveColorStops,
            bezier: widget.bezier,
            thumbRadius: widget.thumbRadius,
            thumbActiveRadius: widget.thumbActiveRadius,
            curveStrokeScale: widget.curveStrokeScale,
            overlayRadius: widget.overlayRadius,
          ),
        ),
      ),
    );
  }
}

class _PlayerSliderPainter extends CustomPainter {
  _PlayerSliderPainter({
    required this.progressListenable,
    required this.pressListenable,
    required this.sliderType,
    required this.inactiveColor,
    required this.thumbColor,
    required this.overlayColor,
    required this.curveColors,
    required this.curveColorStops,
    required this.bezier,
    required this.thumbRadius,
    required this.thumbActiveRadius,
    required this.curveStrokeScale,
    required this.overlayRadius,
  }) : super(repaint: Listenable.merge([progressListenable, pressListenable]));

  final ValueListenable<double> progressListenable;
  final ValueListenable<double> pressListenable;
  final PlayerSliderType sliderType;
  final Color inactiveColor;
  final Color thumbColor;
  final Color overlayColor;
  final List<Color> curveColors;
  final List<double> curveColorStops;
  final double bezier;
  final double thumbRadius;
  final double thumbActiveRadius;
  final double curveStrokeScale;
  final double overlayRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final double normalized = progressListenable.value.clamp(0.0, 1.0);
    final double press = pressListenable.value.clamp(0.0, 1.0);
    final double radius =
        thumbRadius + (thumbActiveRadius - thumbRadius) * press;
    final Offset thumbCenter;

    if (sliderType == PlayerSliderType.curve) {
      // 端点落在组件底边、控制点取 -bezier，与底部蒙版曲线端点/中点对齐。
      final Path path = Path()
        ..moveTo(0, size.height)
        ..quadraticBezierTo(
          size.width / 2,
          -bezier,
          size.width,
          size.height,
        );

      final ui.PathMetric metric = path.computeMetrics().first;
      final double end = metric.length * normalized;
      final Path activePath = metric.extractPath(0, end);
      final ui.Gradient gradient = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, 0),
        curveColors,
        curveColorStops,
      );
      canvas.drawPath(
        activePath,
        Paint()
          ..shader = gradient
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * curveStrokeScale
          ..strokeCap = StrokeCap.round,
      );

      thumbCenter =
          metric.getTangentForOffset(end)?.position ??
          Offset(size.width * normalized, size.height);
    } else {
      // 直线轨道垂直居中：只把曲线的拱形拉平，渐变色与线宽沿用曲线模式，
      // 两种模式视觉一致，切换时不会有粗细或颜色的跳变。
      final double baseY = size.height / 2;
      final double strokeWidth = radius * curveStrokeScale;
      thumbCenter = Offset(size.width * normalized, baseY);

      canvas.drawLine(
        Offset(0, baseY),
        Offset(size.width, baseY),
        Paint()
          ..color = inactiveColor
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );

      if (normalized > 0) {
        // 渐变按整条轨道铺开，激活段只截取其中与进度对应的部分，与曲线模式一致。
        final ui.Gradient gradient = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, 0),
          curveColors,
          curveColorStops,
        );
        canvas.drawLine(
          Offset(0, baseY),
          thumbCenter,
          Paint()
            ..shader = gradient
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    if (press > 0) {
      canvas.drawCircle(
        thumbCenter,
        overlayRadius * press,
        Paint()..color = overlayColor.withValues(alpha: overlayColor.a * press),
      );
    }

    final Path thumb = Path()
      ..addArc(
        Rect.fromCircle(center: thumbCenter, radius: radius),
        0,
        math.pi * 2,
      );
    canvas.drawShadow(thumb, const Color(0x40000000), 2 + 4 * press, true);
    canvas.drawCircle(thumbCenter, radius, Paint()..color = thumbColor);
  }

  @override
  bool shouldRepaint(covariant _PlayerSliderPainter oldDelegate) =>
      // 进度与 press 由 repaint Listenable 驱动，此处只比较样式参数。
      sliderType != oldDelegate.sliderType ||
      inactiveColor != oldDelegate.inactiveColor ||
      thumbColor != oldDelegate.thumbColor ||
      overlayColor != oldDelegate.overlayColor ||
      !_sameColors(curveColors, oldDelegate.curveColors) ||
      !_sameDoubles(curveColorStops, oldDelegate.curveColorStops) ||
      bezier != oldDelegate.bezier ||
      thumbRadius != oldDelegate.thumbRadius ||
      thumbActiveRadius != oldDelegate.thumbActiveRadius ||
      curveStrokeScale != oldDelegate.curveStrokeScale ||
      overlayRadius != oldDelegate.overlayRadius;

  static bool _sameColors(List<Color> a, List<Color> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _sameDoubles(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
