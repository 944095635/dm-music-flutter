import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';
import 'package:flutter/material.dart' hide Gradient;

final Path path = parseSvgPathData(
    "M0,21.8798C49.6423,7.36726,113.618,0,190,0C266.382,0,330.358,7.36726,380,21.8798L380,103L0,103L0,21.8798Z");

class BottomPainter extends CustomPainter {
  BottomPainter(this.factor, this.color, this.progressColor)
      : super(repaint: factor);

  final Color color;

  final Color progressColor;

  /// 监听器
  final ValueNotifier<double> factor;

  double progress = 0;

  @override
  void paint(Canvas canvas, Size size) {
    var pathPaint = Paint()..color = color;

    /// 获取SVG的宽度
    double svgWidth = path.getBounds().width;
    // 定义缩放变换矩阵
    Matrix4 matrix = Matrix4.identity();
    double scale = size.width / svgWidth;
    // 在X和Y轴上缩放
    matrix.scale(scale);
    Path drawPath = Path();
    drawPath = path.transform(matrix.storage);
    canvas.drawPath(drawPath, pathPaint);

    var gradient = Gradient.linear(
      Offset.zero,
      Offset(size.width, 0),
      [
        const Color(0xFFB7EAFF),
        const Color(0xFF7ED9FF),
        const Color(0xFF0F7BAA),
        // Colors.red, Colors.blue, Colors.yellow,
      ],
      [
        0,
        0.6,
        1,
      ],
    );

    // 绘制扇形进度条
    var arcPaint = Paint()
      //..color = progressColor
      ..shader = gradient
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    // 测量Path
    PathMetrics pathMetrics = drawPath.computeMetrics();
    // 获取第一小节信息(猜测可能有多个Path叠加？)
    PathMetric pathMetric = pathMetrics.first;
    // 整个Path的长度
    double length = pathMetric.length;
    // 当前进度
    double value = length * 0.4158 * factor.value;
    Path extractPath = pathMetric.extractPath(0, value, startWithMoveTo: true);
    canvas.drawPath(extractPath, arcPaint);
  }

  @override
  bool shouldRepaint(covariant BottomPainter oldDelegate) {
    return color != oldDelegate.color || progress != oldDelegate.progress;
  }

  // @override
  // bool? hitTest(Offset position) => true;

  // @override
  // SemanticsBuilderCallback? get semanticsBuilder => null;

  // @override
  // bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;

  /// 更新 状态
  // void update(double newprogress) {
  //   progress = newprogress;
  //   notifyListeners();
  // }
}
