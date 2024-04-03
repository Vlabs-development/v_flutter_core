import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/src/hooks/use_keys.dart';

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
