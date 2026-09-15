import 'package:flutter/cupertino.dart';

/// 设置标题项
class SettingsTitleItem extends StatelessWidget {
  const new(this.title, {super.key, this.subTitle});

  /// 标题
  final String title;

  /// 子标题
  final String? subTitle;

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: .w500),
    );
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12),
      child: subTitle != null
          ? Column(
              spacing: 4,
              crossAxisAlignment: .start,
              children: [
                titleWidget,
                Text(subTitle!),
              ],
            )
          : titleWidget,
    );
  }
}
