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
    Function(Object error, StackTrace stackTrace)? onError,
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool broadcast = false,
  }) {
    late final StreamController<T> streamController;
    ProviderSubscription<AsyncValue<T>>? providerSubscription;

    void handleListen() {
      providerSubscription = listen(
        provider,
        (_, next) => next.whenOrNull(
          data: (value) => streamController.add(value),
          error: (error, stackTrace) {
            onError?.call(error, stackTrace);

            if (!skipError) {
              streamController.addError(error, stackTrace);
            }
          },
          skipLoadingOnRefresh: skipLoadingOnRefresh,
          skipLoadingOnReload: skipLoadingOnReload,
        ),
        fireImmediately: fireImmediately,
      );
    }

    void cleanup() {
      providerSubscription?.close();
      streamController.close();
    }

    onDispose(() => cleanup());

    if (broadcast) {
      streamController = StreamController<T>.broadcast(onListen: handleListen, onCancel: cleanup);
    } else {
      streamController = StreamController<T>(onListen: handleListen, onCancel: cleanup);
    }

    return streamController.stream;
  }

  /// Returns a Stream of the values provided by [provider] (which provides items of [T] type).
  /// Especially useful to get the values of a provider, but
  /// do not rebuild [this] when the dependency rebuilds. ([ref.listen] is used internally)
  Stream<T> streamOf<T>(
    AlwaysAliveProviderListenable<T> provider, {
    bool fireImmediately = false,
    bool broadcast = false,
  }) {
    late final StreamController<T> controller;
    ProviderSubscription<T>? providerSubscription;

    void handleListen() {
      providerSubscription = listen(
        provider,
        (_, next) => controller.add(next),
        fireImmediately: fireImmediately,
      );
    }

    void cleanup() {
      providerSubscription?.close();
      controller.close();
    }

    onDispose(() => cleanup());

    if (broadcast) {
      controller = StreamController<T>.broadcast(onListen: handleListen, onCancel: cleanup);
    } else {
      controller = StreamController<T>(onListen: handleListen, onCancel: cleanup);
    }

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
    bool skipError = true,
    Function(Object error, StackTrace stackTrace)? onError,
    bool skipLoadingOnReload = false,
    bool skipLoadingOnRefresh = true,
    bool broadcast = false,
  }) {
    late final StreamController<T> streamController;
    ProviderSubscription<AsyncValue<T>>? providerSubscription;

    void handleListen() {
      providerSubscription = listen(
        provider,
        (_, next) => next.whenOrNull(
          data: (value) => streamController.add(value),
          error: (error, stackTrace) {
            onError?.call(error, stackTrace);

            if (!skipError) {
              streamController.addError(error, stackTrace);
            }
          },
          skipLoadingOnRefresh: skipLoadingOnRefresh,
          skipLoadingOnReload: skipLoadingOnReload,
        ),
        fireImmediately: fireImmediately,
      );
    }

    void cleanup() {
      providerSubscription?.close();
      streamController.close();
    }

    onDispose(() => cleanup());

    if (broadcast) {
      streamController = StreamController<T>.broadcast(onListen: handleListen, onCancel: cleanup);
    } else {
      streamController = StreamController<T>(onListen: handleListen, onCancel: cleanup);
    }

    return streamController.stream;
  }

  /// Returns a Stream of the values provided by [provider] (which provides items of [T] type).
  /// Especially useful to get the values of a provider, but
  /// do not rebuild [this] when the dependency rebuilds. ([ref.listen] is used internally)
  Stream<T> streamOf<T>(
    ProviderListenable<T> provider, {
    bool fireImmediately = false,
    bool broadcast = false,
  }) {
    late final StreamController<T> controller;
    ProviderSubscription<T>? providerSubscription;

    void handleListen() {
      providerSubscription = listen(
        provider,
        (_, next) => controller.add(next),
        fireImmediately: fireImmediately,
      );
    }

    void cleanup() {
      providerSubscription?.close();
      controller.close();
    }

    onDispose(() => cleanup());

    if (broadcast) {
      controller = StreamController<T>.broadcast(onListen: handleListen, onCancel: cleanup);
    } else {
      controller = StreamController<T>(onListen: handleListen, onCancel: cleanup);
    }

    return controller.stream;
  }
}
