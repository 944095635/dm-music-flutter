class HttpResult {
  // 该任务状态
  late bool status;

  // 消息
  String? msg;

  // 返回的数据
  dynamic data;

  HttpResult({
    this.status = false,
    this.msg,
    this.data,
  });
}
