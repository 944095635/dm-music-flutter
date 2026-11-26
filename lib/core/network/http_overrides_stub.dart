/// web 端没有 dart:io，浏览器请求由自身管理 UA，无需也无法设置 HttpOverrides。
///
/// 与 http_overrides_io.dart 构成条件导入的两端，保证 main 侧调用一致。
void installHttpOverrides() {}
