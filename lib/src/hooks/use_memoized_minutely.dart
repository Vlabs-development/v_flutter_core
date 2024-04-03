import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/src/utils/notify_every_minute.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

R useMemoizedMinutely<R>(R Function() valueBuilder, [List<Object?> keys = const []]) {
  final notifyEveryMinute = useMemoized(() => NotifyEveryMinute(), keys);
  useCleanup(notifyEveryMinute.dispose, keys);

  return useMemoized2(
    valueBuilder,
    keys,
    [notifyEveryMinute],
  );
}
