import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/src/hooks/use_keys.dart';

/// Similar to [useMemoized] but it also receives an additional array of [Listenable] objects.
/// When any of the supplied listenable notifies then it will mark the caller [HookWidget]
/// as needing a build.
R useMemoized2<R>(
  R Function() valueBuilder, [
  List<Object?>? keys,
  List<Listenable>? listenableKeys,
]) {
  return useMemoized(
    valueBuilder,
    useEffectiveKeys(keys: keys, listenableKeys: listenableKeys) ?? [],
  );
}
