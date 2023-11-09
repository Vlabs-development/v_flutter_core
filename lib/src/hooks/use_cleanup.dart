import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void useCleanup(Dispose cleanup, [List<Object?> keys = const <Object>[]]) {
  useEffect(
    () => cleanup,
    keys,
  );
}

void useCleanupOnce(Dispose cleanup) {
  useEffect(
    () => cleanup,
    [],
  );
}

void usePostFrameCleanup(Dispose cleanup) {
  useEffect(
    () => () => WidgetsBinding.instance.addPostFrameCallback(
          (_) => cleanup(),
        ),
    [],
  );
}
