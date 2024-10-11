import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

extension CoreStreamExtensions<T> on Stream<T> {
  Stream<T> printEvents(String name, {String? prefix = ''}) {
    return doOnListen(() => debugPrint('👂 $prefix[$name] listen (isBroadcast: $isBroadcast)'))
        .doOnData((event) => debugPrint('💡 $prefix[$name] data $event'))
        .doOnCancel(() => debugPrint('💔 $prefix[$name] cancel'))
        .doOnError((error, stackTrace) => debugPrint('❌ $prefix[$name] error $error $stackTrace'))
        .doOnPause(() => debugPrint('💤 $prefix[$name] pause'))
        .doOnResume(() => debugPrint('💪 $prefix[$name] resume'))
        .doOnDone(() => debugPrint('🏁 $prefix[$name] done'));
  }
}
