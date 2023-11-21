import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/src/hooks/change_notifier_hooks.dart';

/// Ensure that this is not called with different number of keys across builds.
int useListenableKeys(List<Listenable>? listenableKeys) {
  if (listenableKeys?.isEmpty ?? true) {
    return -1;
  }

  final trigger = useState(DateTime.now().microsecondsSinceEpoch);

  for (final listenableKey in listenableKeys ?? <Listenable>[]) {
    useOnChangeNotifierNotified(
      listenableKey,
      () => trigger.value = DateTime.now().microsecondsSinceEpoch,
      listenableKeys,
    );
  }

  return trigger.value;
}

List<Object?>? useEffectiveKeys({required List<Object?>? keys, required List<Listenable>? listenableKeys}) {
  List<Object?>? effectiveKeys;

  if (keys != null) {
    effectiveKeys = [...keys];
  }
  if (listenableKeys != null) {
    effectiveKeys ??= [];
    effectiveKeys.add(useListenableKeys(listenableKeys));
  }

  return effectiveKeys;
}
