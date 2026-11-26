import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

/// 模糊容器：对下层内容做背景模糊，可选圆角与叠加的半透明色。
///
/// [sigmaX]/[sigmaY] 控制横纵向模糊强度；[radius] 为裁剪圆角；
/// [color] 叠在模糊层之上，默认半透明黑，传 null 则不添加装饰层。
/// [child] 为空时默认铺满 [SizedBox.expand]。
class BlurView extends StatelessWidget {
  const BlurView({
    super.key,
    this.child,
    this.sigmaX = 15,
    this.sigmaY = 15,
    this.radius = BorderRadius.zero,
    this.color = const Color(0x68000000),
  });

  /// 绘制在模糊层之上的内容，为空时默认铺满。
  final Widget? child;

  /// 横向模糊强度。
  final double sigmaX;

  /// 纵向模糊强度。
  final double sigmaY;

  /// 裁剪圆角。
  final BorderRadius radius;

  /// 叠在模糊层之上的颜色，默认半透明黑；传 null 则不添加装饰层。
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // 用最终的子节点包一层可空装饰层：color 为 null 时直接返回内容。
    // BackdropFilter 必须有 child 才有模糊区域，因此默认补 SizedBox.expand。
    final Widget content = child ?? const SizedBox.expand();
    final Widget decorated = color == null
        ? content
        : DecoratedBox(
            decoration: BoxDecoration(color: color),
            child: content,
          );

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: decorated,
      ),
    );
  }
}
