import 'package:leviathan_app/app/core/interfaces/success.dart';

extension ResultExtensions<T> on Result<T> {
  void deconstruction({
    void Function(Object error)? failure,
    void Function()? empty,
    void Function()? switchBreak,
    void Function(bool isLoading)? loading,
    void Function()? onEnd,
    void Function(T data, String? description)? success,
  }) {
    final result = this;

    switch (result) {
      case Failure<T>():
        failure?.call(result.error);
        break;
      case Success<T>():
        success?.call(result.data, result.description);
        break;
      case Loading<T>():
        loading?.call(result.isLoading);
        break;
      case Empty<T>():
        empty?.call();
        break;
      default:
        switchBreak?.call();
        break;
    }
    onEnd?.call();
  }
}
