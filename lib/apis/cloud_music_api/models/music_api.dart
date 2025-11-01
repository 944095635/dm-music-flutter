class MusicApi {
  // 地址
  String host;
  // 地址
  String path;
  // Http method
  String method;
  // 参数
  Map<String, dynamic> parameters;

  MusicApi({
    required this.host,
    required this.path,
    required this.method,
    required this.parameters,
  });
}
