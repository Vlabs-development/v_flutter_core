import 'dart:async';

import 'package:flutter/foundation.dart';

class DisposableMapGroup<KeyType, SubKeyType> {
  DisposableMapGroup({this.onDispose});

  Map<KeyType, Map<SubKeyType, VoidCallback>> cleanupCallbacks = {};
  VoidCallback? onDispose;

  void addStreamSubscription(KeyType key, SubKeyType subKey, StreamSubscription<dynamic> sub) {
    addDisposing(key, subKey, sub.cancel);
  }

  void addOrReplaceStreamSubscription(KeyType key, SubKeyType subKey, StreamSubscription<dynamic> sub) {
    addOrReplaceDisposing(key, subKey, sub.cancel);
  }

  void addDisposing(KeyType key, SubKeyType subKey, VoidCallback cleanup) {
    if (!cleanupCallbacks.containsKey(key)) {
      cleanupCallbacks[key] = {};
    }
    if (cleanupCallbacks[key]!.containsKey(subKey)) {
      throw 'Disposable for key $key and subKey $subKey already exists!';
    }
    cleanupCallbacks[key]![subKey] = cleanup;
  }

  void addOrReplaceDisposing(KeyType key, SubKeyType subKey, VoidCallback cleanup) {
    if (!cleanupCallbacks.containsKey(key)) {
      cleanupCallbacks[key] = {};
    }
    if (cleanupCallbacks[key]!.containsKey(subKey)) {
      cleanupCallbacks[key]![subKey]!.call();
      debugPrint('__ a disposable already exists under $key > $subKey, disposing that and storing new one.');
    }
    cleanupCallbacks[key]![subKey] = cleanup;
  }

  void removeByKey(KeyType key) {
    if (cleanupCallbacks.containsKey(key)) {
      final subMap = cleanupCallbacks.remove(key);
      subMap?.forEach((_, cleanup) => cleanup());
    }
  }

  void removeByKeys(KeyType key, SubKeyType subKey) {
    if (cleanupCallbacks.containsKey(key)) {
      final subMap = cleanupCallbacks[key];
      if (subMap != null && subMap.containsKey(subKey)) {
        final cleanup = subMap.remove(subKey);
        cleanup?.call();
      }
    }
  }

  bool containsKeys(KeyType key, SubKeyType subKey) {
    return cleanupCallbacks.containsKey(key) && cleanupCallbacks[key]!.containsKey(subKey);
  }

  Iterable<SubKeyType> getSubKeys(KeyType key) {
    if (cleanupCallbacks.containsKey(key)) {
      return cleanupCallbacks[key]!.keys;
    }

    return [];
  }

  Iterable<SubKeyType> getAllSubKeys() => cleanupCallbacks.values.map((e) => e.keys).expand((e) => e);

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
