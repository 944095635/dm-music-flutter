import 'package:material_ui/material_ui.dart';

/// 通用空数据视图，展示一行提示文字。
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.message = '暂无数据'});

  /// 提示文字。
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(child: Text(message)),
  );
}
