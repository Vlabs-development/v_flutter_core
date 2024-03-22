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
