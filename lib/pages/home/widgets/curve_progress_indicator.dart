import 'dart:ui';

import 'package:flutter/material.dart' hide Gradient;
import 'package:get/get.dart';

/// 圆弧进度条
class CurveProgressIndicator extends StatelessWidget {
  const CurveProgressIndicator({
    super.key,
    this.size = Size.zero,
    this.onChanged,
    required this.progress,
  });

  /// 监听器
  final Rx<double> progress;

  /// 尺寸
  final Size size;

  /// 进度变化
  final Function(double progress)? onChanged;

  @override
  Widget build(BuildContext context) {
    debugPrint("重绘:底部进度条.");
    Size renderSize = MediaQuery.of(context).size;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (details) {
        double value = details.localPosition.dx / renderSize.width;
        debugPrint("百分比进度:$value");
        onChanged?.call(value);
      },
      child: RepaintBoundary(
        child: CustomPaint(
          size: size,
          painter: CurveProgressIndicatorPainter(progress),
        ),
      ),
    );
  }
}

/// 圆弧进度条的绘制器
class CurveProgressIndicatorPainter extends CustomPainter {
  const CurveProgressIndicatorPainter(this.factor) : super(repaint: factor);

  /// 监听器
  final Rx<double> factor;

  @override
  void paint(Canvas canvas, Size size) {
    if (factor.value == 0) {
      //没有进度不绘制
      return;
    }
    debugPrint("重绘:底部进度条-画刷");

    // 贝塞尔曲率
    //double bezier = size.height / 4;

    // 绘制弧线
    // Path line = Path()
    //   ..moveTo(0, bezier)
    //   ..quadraticBezierTo(size.width / 2, -bezier, size.width, bezier);
    Path line = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width / 2,
        -size.height,
        size.width,
        size.height,
      );

    // 定义画刷
    var gradient = Gradient.linear(
      Offset.zero,
      Offset(size.width, 0),
      [
        const Color(0xFFB7EAFF),
        const Color(0xFF7ED9FF),
        const Color(0xFF0F7BAA),
        // Colors.red, Colors.blue, Colors.yellow,
      ],
      [0, 0.6, 1],
    );

    // 绘制扇形进度条
    var paint = Paint()
      //..color = progressColor
      ..shader = gradient
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    //计算百分比进度条
    PathMetrics pathMetrics = line.computeMetrics();
    // 获取第一小节信息(猜测可能有多个Path叠加？)
    PathMetric pathMetric = pathMetrics.first;
    // 整个Path的长度
    double length = pathMetric.length;
    // 当前进度
    double value = length * factor.value;
    Path extractPath = pathMetric.extractPath(0, value, startWithMoveTo: true);
    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  @override
  bool? hitTest(Offset position) {
    return false;
  }
}
