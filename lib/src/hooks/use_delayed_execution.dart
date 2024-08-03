import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

/// Executes a callback function after a specified delay.
///
/// This hook allows for delayed execution of a callback function.
/// The execution is cancelled if the widget is unmounted before the delay completes.
void useDelayedExecution(
  VoidCallback callback, {
  required Duration delay,
}) {
  final savedCallback = useRef<VoidCallback>(() {});
  usePlainEffect(() => savedCallback.value = callback);

  final completer = useMemoized(() => Completer(), [delay]);

  useEffect(
    () {
      final timer = Future.delayed(delay, () {
        if (!completer.isCompleted) {
          savedCallback.value();
        }
      });
      return () {
        timer.ignore();
        if (!completer.isCompleted) {
          completer.complete();
        }
      };
    },
    [delay],
  );
}
