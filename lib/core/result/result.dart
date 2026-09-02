import '../error/network_error.dart';

/// 轻量 Result 类型，Provider 层统一返回值。
sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(T value) ok,
    required R Function(NetworkError error) err,
  }) {
    final self = this;
    return switch (self) {
      Ok<T>(:final value) => ok(value),
      Err<T>(:final error) => err(error),
    };
  }

  T getOrThrow() => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>(:final error) => throw error,
  };

  T? getOrNull() => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.error);
  final NetworkError error;
}
