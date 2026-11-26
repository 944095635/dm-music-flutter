import 'package:material_ui/material_ui.dart';

/// 首页底部播放区的圆弧背景，顶部是一条向上凸的二次贝塞尔曲线。
class PlayerCurveBackdrop extends StatelessWidget {
  const PlayerCurveBackdrop({
    super.key,
    required this.size,
    required this.color,
  });

  /// 绘制区域尺寸，宽度铺满、高度为底部控制区高度。
  final Size size;

  /// 背景填充色。
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _PlayerCurveBackdropPainter(color: color),
    );
  }
}

class _PlayerCurveBackdropPainter extends CustomPainter {
  const _PlayerCurveBackdropPainter({required this.color});

  /// 背景填充色。
  final Color color;

  /// 曲线凸起的弧度。
  static const double _curveHeight = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, _curveHeight)
      ..quadraticBezierTo(
        size.width / 2,
        -_curveHeight,
        size.width,
        _curveHeight,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PlayerCurveBackdropPainter oldDelegate) =>
      color != oldDelegate.color;
}
