import 'dart:ui';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/src/hooks/use_cleanup.dart';

/// Returns a [VoidCallback] which throttles the [callback] by [duration].
/// Many subsequent calls to the returned [VoidCallback] will only result in an actual `callback` invocation
/// once the [duration] has passed since the last call.
VoidCallback useThrottleCallback({
  required VoidCallback callback,
  Duration duration = const Duration(milliseconds: 300),
  List<Object?> keys = const <Object>[],
}) {
  final uniqueTag = useMemoized(() => DateTime.now().millisecondsSinceEpoch.toString());
  final tag = 'useThrottleCallback-$uniqueTag';

  useCleanup(() => EasyThrottle.cancel(tag), keys);
  return () => EasyThrottle.throttle(
        tag,
        duration,
        () => callback(),
      );
}

class CancelableThrottledVoidCallback {
  CancelableThrottledVoidCallback({
    required this.callback,
    this.duration = const Duration(milliseconds: 300),
  }) : tag = 'CancelableThrottledVoidCallback-${DateTime.now().microsecondsSinceEpoch}';

  final VoidCallback callback;
  final Duration duration;
  final String tag;

  void call() => EasyThrottle.throttle(
        tag,
        duration,
        () => callback(),
      );

  void cancel() => EasyThrottle.cancel(tag);
}

/// Returns a [CancelableThrottledVoidCallback] which is essentially a throttled [VoidCallback] with the additional
/// benefit of having a `cancel` method.
CancelableThrottledVoidCallback useCancelableThrottleCallback({
  required VoidCallback callback,
  Duration duration = const Duration(milliseconds: 300),
  List<Object?> keys = const <Object>[],
}) {
  final effectiveCallback = useMemoized(
    () => CancelableThrottledVoidCallback(
      callback: callback,
      duration: duration,
    ),
    keys,
  );

  useCleanup(() => effectiveCallback.cancel(), keys);
  return effectiveCallback;
}
