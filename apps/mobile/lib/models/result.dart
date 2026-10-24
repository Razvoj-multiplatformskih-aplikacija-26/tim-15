sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Failure<T> extends Result<T> {
  final Object error;
  const Failure(this.error);
}

extension ResultX<T> on Result<T> {
  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };
  Object? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final error) => error,
  };
}