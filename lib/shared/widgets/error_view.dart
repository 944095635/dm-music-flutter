import 'package:material_ui/material_ui.dart';

/// 通用错误视图，展示错误信息，可带一个重试按钮。
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  /// 错误信息。
  final String message;

  /// 重试回调。为 null 时不显示重试按钮。
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      spacing: 8,
      // 让视图高度贴合内容，放进 Center 时能真正居中显示。
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        if (onRetry != null) ...[
          TextButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ],
    ),
  );
}
