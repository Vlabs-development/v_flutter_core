import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_core/src/hooks/use_keys.dart';

GlobalKey useGlobalKey() => useState(GlobalKey()).value;

R useMemoized2<R, T extends ChangeNotifier>(
  R Function() valueBuilder, [
  List<Object?>? keys,
  List<Listenable>? listenableKeys,
]) {
  return useMemoized(
    valueBuilder,
    useEffectiveKeys(keys: keys, listenableKeys: listenableKeys) ?? [],
  );
}
