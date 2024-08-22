import 'dart:async';

import 'package:flutter/foundation.dart';

class DisposableMap<IDType> {
  DisposableMap({this.onDispose});

  Map<IDType, VoidCallback> cleanupCallbacks = {};
  // Map<IDType, StreamSubscription<dynamic>> streamSubscriptions = {};
  VoidCallback? onDispose;

  void addStreamSubscription(IDType key, StreamSubscription<dynamic> sub) {
    // streamSubscriptions.putIfAbsent(key, () => sub);
    addDisposing(key, () => sub.cancel());
  }

  // StreamSubscription<dynamic>? getSubscription(IDType id) {
  //   return streamSubscriptions[id];
  // }

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
    cleanupCallbacks.clear();

    // for (final sub in streamSubscriptions.values) {
    //   sub.cancel();
    // }
    // streamSubscriptions.clear();

    onDispose?.call();
  }
}
