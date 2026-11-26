import 'package:dio/dio.dart';

import 'package:dm_music/core/network/api_endpoints.dart';

/// 创建并配置 HTTP 客户端。
///
/// 以工厂方法提供实例，便于在测试中注入替换。
Dio createDioClient() => Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
