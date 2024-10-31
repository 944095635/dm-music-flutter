import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

final Path path = parseSvgPathData(
    "M0,19.9933C130.949,-6.57198,212.947,-6.75674,375,19.9933C375,19.9933,375,99.9933,375,99.9933C375,99.9933,0,99.9933,0,99.9933C0,99.9933,0,19.9933,0,19.9933C0,19.9933,0,19.9933,0,19.9933Z");

class BottomPainter extends CustomPainter {
  BottomPainter(this.color);

  final Color color;

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
    canvas.drawShadow(drawPath, Colors.black, 10, false);
    canvas.drawPath(drawPath, pathPaint);

    // 绘制扇形进度条
  }

  @override
  bool shouldRepaint(covariant BottomPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
