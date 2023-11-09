import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_core/src/hooks/use_keys.dart';

void useAsyncEffect(Future<Dispose?> Function() effect, [List<Object?>? keys, List<Listenable>? listenableKeys]) {
  useEffect(
    () {
      final disposeFuture = Future.microtask(effect);
      return () => disposeFuture.then((dispose) => dispose?.call());
    },
    useEffectiveKeys(keys: keys, listenableKeys: listenableKeys),
  );
}

void useAsyncEffectOnce(Future<Dispose?> Function() effect) {
  useAsyncEffect(
    effect,
    [],
  );
}

void usePlainAsyncEffect(Future<void> Function() effect, [List<Object?>? keys, List<Listenable>? listenableKeys]) {
  useAsyncEffect(
    () async {
      await effect();
      return null;
    },
    useEffectiveKeys(keys: keys, listenableKeys: listenableKeys),
  );
}

void usePlainAsyncEffectOnce(Future<void> Function() effect) {
  usePlainAsyncEffect(
    () async => await effect(),
    [],
  );
}
