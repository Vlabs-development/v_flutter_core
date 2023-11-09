import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_core/src/hooks/use_keys.dart';

typedef DisposableEffect = Dispose? Function();
typedef PlainEffect = void Function();

/// Syntax sugar for omitting the [keys] array.
void useEffectOnce(DisposableEffect effect) {
  useEffect(
    effect,
    [],
  );
}

/// Syntax sugar for having an effect which returns null
void usePlainEffect(PlainEffect effect, [List<Object?>? keys, List<Listenable>? listenableKeys]) {
  useEffect(
    () {
      effect();
      return null;
    },
    useEffectiveKeys(keys: keys, listenableKeys: listenableKeys),
  );
}

/// Syntax sugar for omitting the [keys] array and allowing
/// call site to pass the effect as expression body.
void usePlainEffectOnce(PlainEffect effect) {
  usePlainEffect(
    () => effect(),
    [],
  );
}

void usePostFrameEffect(DisposableEffect effect, [List<Object?>? keys, List<Listenable>? listenableKeys]) {
  useEffect(
    () {
      Dispose? dispose;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => dispose = effect(),
      );
      return () => dispose?.call();
    },
    useEffectiveKeys(keys: keys, listenableKeys: listenableKeys),
  );
}

void usePostFrameEffectOnce(Dispose Function() effect) {
  usePostFrameEffect(
    effect,
    [],
  );
}

void usePlainPostFrameEffect(PlainEffect effect, [List<Object?>? keys, List<Listenable>? listenableKeys]) {
  usePostFrameEffect(
    () {
      effect();
      return null;
    },
    useEffectiveKeys(keys: keys, listenableKeys: listenableKeys),
  );
}

void usePlainPostFrameEffectOnce(PlainEffect effect) => usePlainPostFrameEffect(
      effect,
      [],
    );
