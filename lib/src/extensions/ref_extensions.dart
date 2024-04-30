import 'dart:async';

import 'package:riverpod/riverpod.dart';

extension CoreRefExtensions on Ref<dynamic> {
  /// Returns a Stream of [AsyncData] values provided by [provider] (which provides items of [AsyncValue<T>] type).
  /// Especially useful to get the values of a provider, but
  /// do not rebuild [this] when the dependency rebuilds. ([ref.listen] is used internally)
  Stream<T> streamOfAsyncData<T>(
    AlwaysAliveProviderListenable<AsyncValue<T>> provider, {
    bool fireImmediately = false,
    bool skipAsyncError = true,
  }) {
    final StreamController<T> controller = StreamController();

    listen(
      provider,
      (_, next) => next.whenOrNull(
        data: (value) => controller.add(value),
        error: (error, stackTrace) => skipAsyncError ? null : controller.addError(error, stackTrace),
      ),
      fireImmediately: fireImmediately,
    );
    onDispose(() => controller.close());

    return controller.stream;
  }

  /// Returns a Stream of the values provided by [provider] (which provides items of [T] type).
  /// Especially useful to get the values of a provider, but
  /// do not rebuild [this] when the dependency rebuilds. ([ref.listen] is used internally)
  Stream<T> streamOf<T>(
    AlwaysAliveProviderListenable<T> provider, {
    bool fireImmediately = false,
  }) {
    final StreamController<T> controller = StreamController();

    listen(
      provider,
      (_, next) => controller.add(next),
      fireImmediately: fireImmediately,
    );
    onDispose(() => controller.close());

    return controller.stream;
  }
}

extension CoreAutoDisposeRefExtensions on AutoDisposeRef<dynamic> {
  /// Returns a Stream of [AsyncData] values provided by [provider] (which provides items of [AsyncValue<T>] type).
  /// Especially useful to get the values of a provider, but
  /// do not rebuild [this] when the dependency rebuilds. ([ref.listen] is used internally)
  Stream<T> streamOfAsyncData<T>(
    ProviderListenable<AsyncValue<T>> provider, {
    bool fireImmediately = false,
    bool skipAsyncError = true,
  }) {
    final StreamController<T> controller = StreamController();

    listen(
      provider,
      (_, next) => next.whenOrNull(
        data: (value) => controller.add(value),
        error: (error, stackTrace) => skipAsyncError ? null : controller.addError(error, stackTrace),
      ),
      fireImmediately: fireImmediately,
    );
    onDispose(() => controller.close());

    return controller.stream;
  }

  /// Returns a Stream of the values provided by [provider] (which provides items of [T] type).
  /// Especially useful to get the values of a provider, but
  /// do not rebuild [this] when the dependency rebuilds. ([ref.listen] is used internally)
  Stream<T> streamOf<T>(
    ProviderListenable<T> provider, {
    bool fireImmediately = false,
  }) {
    final StreamController<T> controller = StreamController();

    listen(
      provider,
      (_, next) => controller.add(next),
      fireImmediately: fireImmediately,
    );
    onDispose(() => controller.close());

    return controller.stream;
  }
}
