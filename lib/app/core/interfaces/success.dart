final class Loading<T> extends Result<T> {
  final bool isLoading;
  const Loading(this.isLoading);
}

final class Empty<T> extends Result<T> {
  const Empty();
}

final class Success<T> extends Result<T> {
  final T data;
  final String? description;
  const Success(this.data, {this.description});
}

final class Failure<T> extends Result<T> {
  final Object error;
  const Failure(this.error);
}

sealed class Result<T> {
  const Result();
  const factory Result.success(T data, {String? description}) = Success<T>;
  const factory Result.failure(Object error) = Failure<T>;
  const factory Result.empty() = Empty<T>;
  const factory Result.loading(bool isLoading) = Loading<T>;
}
