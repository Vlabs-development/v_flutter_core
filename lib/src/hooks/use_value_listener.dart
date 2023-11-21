import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/src/hooks/use_effect_hooks.dart';

/// Calls [listener] when [value] changes. If [fireImmediately] is true (the default), [listener] is called immediately.
void useValueListener<T>(
  T value,
  void Function() listener, {
  bool fireImmediately = true,
}) {
  usePlainEffectOnce(() {
    if (fireImmediately) {
      listener();
    }
  });
  useValueChanged<dynamic, dynamic>(value, (_, __) {
    listener();
  });
}
