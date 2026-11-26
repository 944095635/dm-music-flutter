import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:dm_music/shared/widgets/empty_view.dart';
import 'package:dm_music/shared/widgets/error_view.dart';

/// 四状态视图：根据 [value] 的状态展示加载中、数据、空数据或错误界面。
///
/// [value] 处于数据状态时，若 [isEmpty] 判定为空则展示空界面，否则展示数据界面。
/// 各状态的界面均可通过对应回调自定义，未传则用默认界面。
///
/// 用法：
/// ```dart
/// AsyncStateView<List<Song>>(
///   value: ref.watch(songsProvider),
///   isEmpty: (songs) => songs.isEmpty,
///   data: (songs) => SongList(songs),
///   onLoading: () => const Center(child: CircularProgressIndicator()),
///   onEmpty: () => const EmptyView(),
///   onError: (error, _) => ErrorView(message: '$error'),
/// )
/// ```
class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.value,
    required this.data,
    this.isEmpty,
    this.onLoading,
    this.onEmpty,
    this.onError,
  });

  final AsyncValue<T> value;

  /// 正常状态：拿到数据构建 UI。
  final Widget Function(T data) data;

  /// 判定数据是否为空。不传则永远走 [data]，不启用空状态。
  final bool Function(T data)? isEmpty;

  final Widget Function()? onLoading;
  final Widget Function()? onEmpty;

  /// 错误状态，携带 error 与 stackTrace。
  final Widget Function(Object error, StackTrace stack)? onError;

  @override
  Widget build(BuildContext context) {
    return value.when(
      // 刷新时保留旧数据，避免列表闪成 loading（Riverpod 3 默认行为）。
      skipLoadingOnRefresh: true,
      loading: () =>
          onLoading?.call() ?? const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          onError?.call(error, stack) ?? ErrorView(message: '$error'),
      data: (result) {
        if (isEmpty?.call(result) ?? false) {
          return onEmpty?.call() ?? const EmptyView();
        }
        return data(result);
      },
    );
  }
}
