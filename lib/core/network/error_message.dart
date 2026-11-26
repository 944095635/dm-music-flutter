import 'package:dio/dio.dart';

/// 把底层异常转成面向用户的中文提示。
///
/// 只识别 Dio 的网络异常并分类，其余一律给出统一兜底文案，
/// 避免把 DioException 的原始信息（类型名、URL、堆栈等）暴露到界面上。
String friendlyErrorMessage(Object error) {
  if (error is! DioException) return '未知错误，请稍后重试';

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return '网络连接超时，请稍后重试';
    case DioExceptionType.connectionError:
      return '网络连接失败，请检查网络后重试';
    case DioExceptionType.badCertificate:
      return '网络安全证书异常，请稍后重试';
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return '服务器暂时不可用（$statusCode），请稍后重试';
      }
      if (statusCode != null) return '请求失败（$statusCode），请稍后重试';
      return '服务器返回异常，请稍后重试';
    case DioExceptionType.cancel:
      return '请求已取消';
    case DioExceptionType.unknown:
      return '网络异常，请稍后重试';
  }
}
