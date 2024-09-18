import 'dart:async';

import 'package:riverpod/riverpod.dart';

extension CoreRefExtensions on Ref<dynamic> {
  /// Returns a Stream of [AsyncData] values provided by [provider] (which provides items of [AsyncValue<T>] type).
  /// Especially useful to get the values of a provider, but
  /// do not rebuild [this] when the dependency rebuilds. ([ref.listen] is used internally)
  Stream<T> streamOfAsyncData<T>(
    AlwaysAliveProviderListenable<AsyncValue<T>> provider, {
    bool fireImmediately = false,
    bool skipError = true,
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool broadcast = false,
  }) {
    final StreamController<T> controller = broadcast ? StreamController.broadcast() : StreamController();
    onDispose(() => controller.close());

    listen(
      provider,
      (_, next) => next.whenOrNull(
        data: (value) => controller.add(value),
        error: (error, stackTrace) => skipError ? null : controller.addError(error, stackTrace),
        skipLoadingOnRefresh: skipLoadingOnRefresh,
        skipLoadingOnReload: skipLoadingOnReload,
      ),
      fireImmediately: fireImmediately,
    );

    return controller.stream;
  }

  /// Returns a Stream of the values provided by [provider] (which provides items of [T] type).
  /// Especially useful to get the values of a provider, but
  /// do not rebuild [this] when the dependency rebuilds. ([ref.listen] is used internally)
  Stream<T> streamOf<T>(
    AlwaysAliveProviderListenable<T> provider, {
    bool fireImmediately = false,
    bool broadcast = false,
  }) {
    final StreamController<T> controller = broadcast ? StreamController.broadcast() : StreamController();
    onDispose(() => controller.close());

    listen(
      provider,
      (_, next) => controller.add(next),
      fireImmediately: fireImmediately,
    );

    return controller.stream;
  }
}
