import 'dart:async';

import 'package:flutter/foundation.dart';

class DisposableMapGroup<IDType, IDSubType> {
  DisposableMapGroup({this.onDispose});

  Map<IDType, Map<IDSubType, VoidCallback>> cleanupCallbacks = {};
  VoidCallback? onDispose;

  void addStreamSubscription(IDType key, IDSubType subKey, StreamSubscription<dynamic> sub) {
    addDisposing(key, subKey, sub.cancel);
  }

  void addDisposing(IDType key, IDSubType subKey, VoidCallback cleanup) {
    if (!cleanupCallbacks.containsKey(key)) {
      cleanupCallbacks[key] = {};
    }
    if (cleanupCallbacks[key]!.containsKey(subKey)) {
      throw 'Disposable for key $key and subKey $subKey already exists!';
    }
    cleanupCallbacks[key]![subKey] = cleanup;
  }

  void removeByKey(IDType key) {
    if (cleanupCallbacks.containsKey(key)) {
      final subMap = cleanupCallbacks.remove(key);
      subMap?.forEach((_, cleanup) => cleanup());
    }
  }

  void removeByKeys(IDType key, IDSubType subKey) {
    if (cleanupCallbacks.containsKey(key)) {
      final subMap = cleanupCallbacks[key];
      if (subMap != null && subMap.containsKey(subKey)) {
        final cleanup = subMap.remove(subKey);
        cleanup?.call();
      }
    }
  }

  bool containsKeys(IDType key, IDSubType subKey) {
    return cleanupCallbacks.containsKey(key) && cleanupCallbacks[key]!.containsKey(subKey);
  }

  Iterable<IDSubType> getSubKeys(IDType key) {
    if (cleanupCallbacks.containsKey(key)) {
      return cleanupCallbacks[key]!.keys;
    }

    return [];
  }

  void dispose() {
    for (final subMap in cleanupCallbacks.values) {
      for (final cleanup in subMap.values) {
        cleanup.call();
      }
      subMap.clear();
    }
    cleanupCallbacks.clear();
    onDispose?.call();
  }
}
