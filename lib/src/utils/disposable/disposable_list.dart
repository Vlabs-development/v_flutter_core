import 'dart:async';

import 'package:flutter/foundation.dart';

class DisposableList {
  DisposableList({this.onDispose});

  List<VoidCallback> cleanupCallbacks = [];
  VoidCallback? onDispose;

  void addDisposing(VoidCallback cleanup) => cleanupCallbacks.add(cleanup);
  void addAllDisposing(Iterable<VoidCallback> cleanups) => cleanupCallbacks.addAll(cleanups);
  void addStreamSubscription(StreamSubscription<dynamic> sub) => addDisposing(sub.cancel);
  void addAllStreamSubscription(Iterable<StreamSubscription<dynamic>> subs) =>
      addAllDisposing(subs.map((e) => () => unawaited(e.cancel())));

  void dispose() {
    for (final fn in cleanupCallbacks) {
      fn.call();
    }
    cleanupCallbacks.clear();
    onDispose?.call();
  }
}
