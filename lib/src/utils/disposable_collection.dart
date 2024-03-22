import 'dart:async';

import 'package:flutter/foundation.dart';

class DisposableList {
  DisposableList({this.onDispose});

  List<VoidCallback> cleanupCallbacks = [];
  VoidCallback? onDispose;

  void addDisposing(VoidCallback cleanup) => cleanupCallbacks.add(cleanup);
  void addStreamSubscription(StreamSubscription sub) => addDisposing(sub.cancel);

  void dispose() {
    for (final fn in cleanupCallbacks) {
      fn.call();
    }
    onDispose?.call();
  }
}

class DisposableMap<IDType> {
  DisposableMap({this.onDispose});

  Map<IDType, VoidCallback> cleanupCallbacks = {};
  VoidCallback? onDispose;

  void addStreamSubscription(IDType key, StreamSubscription sub) => addDisposing(key, sub.cancel);
  void addDisposing(IDType key, VoidCallback cleanup) {
    if (cleanupCallbacks.containsKey(key)) {
      throw 'Disposable for key $key already exists!';
    }

    cleanupCallbacks.putIfAbsent(key, () => cleanup);
  }

  void removeByKey(IDType key) {
    if (cleanupCallbacks.containsKey(key)) {
      final cleanup = cleanupCallbacks.remove(key);
      cleanup?.call();
    }
  }

  bool containsKey(IDType key) {
    return cleanupCallbacks.containsKey(key);
  }

  void dispose() {
    for (final fn in cleanupCallbacks.values) {
      fn.call();
    }
    onDispose?.call();
  }
}

class DisposableMapGroup<IDType, IDSubType> {
  DisposableMapGroup({this.onDispose});

  Map<IDType, Map<IDSubType, VoidCallback>> cleanupCallbacks = {};
  VoidCallback? onDispose;

  void addStreamSubscription(IDType key, IDSubType subKey, StreamSubscription sub) {
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
    }
    onDispose?.call();
  }
}
