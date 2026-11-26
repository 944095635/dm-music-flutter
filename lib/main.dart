import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:dm_music/app/app.dart';
// native 端注入统一 UA 解决图床 403；web 端走空实现（无 dart:io）。
import 'package:dm_music/core/network/http_overrides_stub.dart'
    if (dart.library.io) 'package:dm_music/core/network/http_overrides_io.dart';

void main() {
  installHttpOverrides();
  runApp(const ProviderScope(child: App()));
}
