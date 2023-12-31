import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/src/hooks/change_notifier_hooks.dart';

void useIsFocusedFor(FocusNode focusNode, Duration duration, VoidCallback callback) {
  final savedCallback = useRef<VoidCallback>(() {});
  final timer = useRef<Timer?>(null);

  // ignore: body_might_complete_normally_nullable
  useEffect(() {
    savedCallback.value = callback;
  });

  useOnChangeNotifierValueChanged(
    focusNode,
    select: (notifier) => notifier.hasFocus,
    onChanged: (value) {
      if (value) {
        timer.value = Timer.periodic(duration, (time) {
          savedCallback.value();
          timer.value?.cancel();
        });
      } else {
        timer.value?.cancel();
        timer.value = null;
      }
    },
  );
}
