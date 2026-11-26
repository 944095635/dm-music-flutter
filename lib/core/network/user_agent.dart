/// 全局统一的浏览器 UA。
///
/// 网易云图床会拦截无 UA 的请求并返回 403，图片与接口请求共用此值，
/// 避免在每个调用点各写一遍。
const String appUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36';
