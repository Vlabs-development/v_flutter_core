import 'package:riverpod_annotation/riverpod_annotation.dart';

extension CoreAsyncValueExtensions<T> on AsyncValue<T> {
  AsyncValue<T> get toLoading {
    final _value = value;
    if (_value != null) {
      return AsyncLoading<T>().copyWithPrevious(AsyncData(_value));
    } else {
      return AsyncLoading<T>();
    }
  }

  AsyncValue<T> toError(Object error, StackTrace stackStrace) {
    final _value = value;
    if (_value != null) {
      return AsyncError<T>(error, stackStrace).copyWithPrevious(AsyncData(_value));
    } else {
      return AsyncError<T>(error, stackStrace);
    }
  }
}
