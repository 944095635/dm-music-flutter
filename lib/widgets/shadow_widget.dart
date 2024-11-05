import 'package:flutter/material.dart';

/// 阴影组件
class ShadowWidget extends StatelessWidget {
  const ShadowWidget({
    super.key,
    this.child,
    this.blurRadius = 10,
    required this.borderRadius,
  });

  final double blurRadius;

  final BorderRadius borderRadius;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            //color: const Color.fromARGB(255, 255, 0, 0),
            color: const Color.fromRGBO(60, 60, 60, 0.2),
            blurRadius: blurRadius,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: child,
    );
  }
}
