import 'dart:async';

import 'package:riverpod/riverpod.dart';

extension CoreRefExtensions on Ref<dynamic> {
  /// Returns a Stream of the values provided by [provided]. Especially useful to get the values of a provider, but
  /// do not rebuild [this] when the dependency rebuilds. ([ref.listen] is used internally)
  Stream<T> streamOf<T>(AlwaysAliveProviderListenable<dynamic> provider) {
    final StreamController<T> controller = StreamController();

    listen(provider, (previous, next) {
      if (next is AsyncValue<T>) {
        next.whenData((value) => controller.add(value));
        return;
      }

      if (next is T) {
        controller.add(next);
        return;
      }

      throw ArgumentError(
        'ref.streamOf was given a provider that does not provide [AsyncValue]$T, but ${next.runtimeType}',
      );
    });
    onDispose(() => controller.close());

    return controller.stream;
  }
}

extension CoreAutoDisposeRefExtensions on AutoDisposeRef<dynamic> {
  /// Returns a Stream of the values provided by [provided]. Especially useful to get the values of a provider, but
  /// do not rebuild [this] when the dependency rebuilds. ([ref.listen] is used internally)
  Stream<T> streamOf<T>(ProviderListenable<dynamic> provider) {
    final StreamController<T> controller = StreamController();

    listen(provider, (previous, next) {
      if (next is AsyncValue<T>) {
        next.whenData((value) => controller.add(value));
        return;
      }

      if (next is T) {
        controller.add(next);
        return;
      }

      throw ArgumentError(
        'ref.streamOf was given a provider that does not provide [AsyncValue]$T, but ${next.runtimeType}',
      );
    });
    onDispose(() => controller.close());

    return controller.stream;
  }
}
