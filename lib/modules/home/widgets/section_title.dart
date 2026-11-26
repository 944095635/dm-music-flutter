import 'package:material_ui/material_ui.dart';

/// 首页分区标题。
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});

  /// 标题文字。
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
