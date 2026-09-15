import 'package:flutter/material.dart';

/// 音乐分类项
class MusicCategoryItem extends StatelessWidget {
  const new(this.category, {super.key});

  /// 音乐分类
  final String category;

  @override
  Widget build(BuildContext context) {
    return Text(
      category,
      style: const TextStyle(fontSize: 18),
    );
  }
}
