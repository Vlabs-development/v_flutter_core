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

  bool get isInitialLoading => isLoading && !isRefreshing && !isReloading;

  T? get actualValueOrNull => when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        data: (data) => data,
        error: (error, stack) => null,
        loading: () => null,
      );

  /// As opposed to [whenData] this mapper function aims to fully take over the [isRefreshing] and [isReloading]
  /// state of the original AsyncValue.
  AsyncValue<R> mapData<R>(R Function(T value) mapper) {
    AsyncValue<R> _guardedMap(T data, R Function(T data) mapper) {
      try {
        return AsyncData<R>(mapper(data));
      } catch (e, s) {
        return AsyncError(e, s);
      }
    }

    return when(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      data: (data) => _guardedMap(data, mapper),
      error: (e, s) => AsyncError(e, s),
      loading: () {
        final actualValueOrNull = this.actualValueOrNull;
        if (hasValue && actualValueOrNull != null) {
          return _guardedMap(actualValueOrNull, mapper).copyWithPrevious(const AsyncLoading(), isRefresh: isRefreshing);
        } else {
          return AsyncLoading<R>().copyWithPrevious(const AsyncLoading(), isRefresh: isRefreshing);
        }
      },
    );
  }
}
