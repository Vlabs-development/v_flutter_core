import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms_annotations/reactive_forms_annotations.dart';
import 'package:v_flutter_core/src/hooks/use_effect_hooks.dart';

void useScrollNotificationObserver(
  BuildContext context, {
  required void Function(ScrollNotification) handler,
  Dispose? dispose,
  List<Object?>? keys,
}) {
  usePostFrameEffect(
    () {
      final observer = ScrollNotificationObserver.maybeOf(context);

      if (observer == null) {
        debugPrint('ScrollNotificationObserver is null');
        return () {};
      }

      observer.addListener(handler);
      return () {
        observer.removeListener(handler);
        dispose?.call();
      };
    },
    keys,
  );
}
