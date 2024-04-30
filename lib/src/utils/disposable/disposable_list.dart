import 'dart:async';

import 'package:flutter/foundation.dart';

class DisposableList {
  DisposableList({this.onDispose});

  List<VoidCallback> cleanupCallbacks = [];
  VoidCallback? onDispose;

  void addDisposing(VoidCallback cleanup) => cleanupCallbacks.add(cleanup);
  void addStreamSubscription(StreamSubscription<dynamic> sub) => addDisposing(sub.cancel);

  void dispose() {
    for (final fn in cleanupCallbacks) {
      fn.call();
    }
    cleanupCallbacks.clear();
    onDispose?.call();
  }
}
