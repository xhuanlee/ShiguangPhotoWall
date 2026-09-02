/// 统一网络错误模型（PRD §17）。
sealed class NetworkError {
  const NetworkError();

  /// 面向用户的提示文案（PRD §43）
  String get userMessage;
}

class Unauthorized extends NetworkError {
  const Unauthorized();
  @override
  String get userMessage => '网盘认证已失效，请重新认证';
}

class Forbidden extends NetworkError {
  const Forbidden();
  @override
  String get userMessage => '当前应用没有访问此文件夹的权限';
}

class NotFound extends NetworkError {
  const NotFound();
  @override
  String get userMessage => '文件已不存在';
}

class RateLimited extends NetworkError {
  const RateLimited();
  @override
  String get userMessage => '请求过于频繁，请稍后重试';
}

class Timeout extends NetworkError {
  const Timeout();
  @override
  String get userMessage => '网络连接超时，请检查网络后重试';
}

class Offline extends NetworkError {
  const Offline();
  @override
  String get userMessage => '网络连接失败，请检查网络后重试';
}

class ServerError extends NetworkError {
  const ServerError(this.code);
  final int code;
  @override
  String get userMessage => '云盘服务暂时不可用（$code），请稍后重试';
}

class UnknownError extends NetworkError {
  const UnknownError(this.cause);
  final Object? cause;
  @override
  String get userMessage => '发生未知错误，请重试';
}

/// Provider 认证相关错误（触发 NEED_REAUTH 状态机）。
class AuthExpiredError implements Exception {
  const AuthExpiredError();
  @override
  String toString() => 'AuthExpiredError';
}

/// 从 Dio/HTTP 异常映射到统一错误模型。
NetworkError mapDioError(Object error) {
  final msg = error.toString();
  if (error is StateError) return UnknownError(error);
  if (msg.contains('SocketException') || msg.contains('Connection refused')) {
    return const Offline();
  }
  if (msg.contains('TimeoutException') || msg.contains('timeout')) {
    return const Timeout();
  }
  return UnknownError(error);
}

/// 根据HTTP状态码映射。
NetworkError mapHttpStatus(int status) {
  switch (status) {
    case 401:
      return const Unauthorized();
    case 403:
      return const Forbidden();
    case 404:
      return const NotFound();
    case 429:
      return const RateLimited();
    default:
      return ServerError(status);
  }
}
