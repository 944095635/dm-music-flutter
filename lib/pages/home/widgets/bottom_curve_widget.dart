import 'package:flutter/material.dart' hide Gradient;

/// 底部圆弧组件
class BottomCurveWidget extends StatelessWidget {
  const BottomCurveWidget({
    super.key,
    required this.size,
    required this.backgroundColor,
  });

  /// 体积大小
  final Size size;

  /// 背景色
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    debugPrint("重绘:底部背景");
    return RepaintBoundary(
      child: CustomPaint(
        size: size,
        painter: BottomCurvePainter(backgroundColor),
      ),
    );
  }
}

/// 底部画刷
class BottomCurvePainter extends CustomPainter {
  BottomCurvePainter(this.backgroundColor);

  /// 背景色
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint("重绘:底部背景-画刷");

    // 贝塞尔曲率
    double bezier = size.height / 4;

    /// 画笔
    // var backgroundPaint = Paint()
    //   ..color = backgroundColor
    //   ..imageFilter = ImageFilter.blur(
    //     sigmaX: 1,
    //     sigmaY: 1,
    //   );

    Path background = Path()
      ..moveTo(0, bezier)
      ..quadraticBezierTo(size.width / 2, -bezier, size.width, bezier)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, bezier)
      ..close();

    //canvas.drawShadow(background, Colors.black, 10, true);
    canvas.clipPath(background);
    canvas.drawColor(backgroundColor, BlendMode.srcIn);
  }

  @override
  bool shouldRepaint(covariant BottomCurvePainter oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor;
  }
}
