import 'dart:ui';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/src/hooks/use_cleanup.dart';

/// Returns a [VoidCallback] which debounces the [callback] by [duration].
/// Many subsequent calls to the returned [VoidCallback] will only result in an actual `callback` invocation
/// once the [duration] has passed since the last call.
VoidCallback useDebounceCallback({
  required VoidCallback callback,
  Duration duration = const Duration(milliseconds: 300),
  List<Object?> keys = const <Object>[],
}) {
  final uniqueTag = useMemoized(() => DateTime.now().millisecondsSinceEpoch.toString());
  final tag = 'useDebounceCallback-$uniqueTag';

  useCleanup(() => EasyDebounce.cancel(tag), keys);
  return () => EasyDebounce.debounce(
        tag,
        duration,
        () => callback(),
      );
}

class CancelableDebouncedVoidCallback {
  final VoidCallback callback;
  final Duration duration;
  final String tag;

  CancelableDebouncedVoidCallback({
    required this.callback,
    this.duration = const Duration(milliseconds: 300),
  }) : tag = 'CancelableDebouncedVoidCallback-${DateTime.now().microsecondsSinceEpoch.toString()}';

  void call() => EasyDebounce.debounce(
        tag,
        duration,
        () => callback(),
      );

  void cancel() => EasyDebounce.cancel(tag);
}

/// Returns a [CancelableDebouncedVoidCallback] which is essentially a debounced [VoidCallback] with the additional
/// benefit of having a `cancel` method.
CancelableDebouncedVoidCallback useCancelableDebounceCallback({
  required VoidCallback callback,
  Duration duration = const Duration(milliseconds: 300),
  List<Object?> keys = const <Object>[],
}) {
  final effectiveCallback = useMemoized(
    () => CancelableDebouncedVoidCallback(
      callback: callback,
      duration: duration,
    ),
    keys,
  );

  useCleanup(() => effectiveCallback.cancel(), keys);
  return effectiveCallback;
}
