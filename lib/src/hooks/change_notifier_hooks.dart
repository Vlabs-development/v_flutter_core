import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Listens to a [ChangeNotifier] and calls [onChange] when it notifies.
/// It is not needed to define the notifier itself as part of the keys.
void useOnChangeNotifierNotified<T extends Listenable>(
  T? notifier,
  VoidCallback onChanged, [
  List<Object?>? keys,
  List<Listenable>? listenableKeys,
]) {
  final trigger = useState(DateTime.now().microsecondsSinceEpoch);

  useEffect(
    () {
      notifier?.addListener(onChanged);
      return () => notifier?.removeListener(onChanged);
    },
    [notifier, trigger.value, ...keys ?? [], ...listenableKeys ?? []],
  );

  for (final listenableKey in listenableKeys ?? <Listenable>[]) {
    useOnChangeNotifierNotified(
      listenableKey,
      () => trigger.value = DateTime.now().microsecondsSinceEpoch,
    );
  }
}

/// Listens to a [ChangeNotifier] and selects a value from it. When that value
/// differs from the previous build's selected value then [onChanged] is called.
void useOnChangeNotifierValueChanged<T extends Listenable, R>(
  T notifier, {
  required R Function(T notifier) select,
  required dynamic Function(R value) onChanged,
  List<Object?>? keys,
  List<Listenable>? listenableKeys,
}) {
  final initialData = select(notifier);
  final value1 = useValueNotifier(initialData);
  final value2 = useValueNotifier(initialData);
  final toggle = useValueNotifier(true);

  void selectValue() {
    final selectedValue = select(notifier);
    // Unfortunatelly usePrevious could not be used here, as this is an anonymus async callback
    // and is not a build of a widget which mixes in `Hook`
    if (toggle.value) {
      value1.value = selectedValue;
    } else {
      value2.value = selectedValue;
    }
    toggle.value = !toggle.value;

    if (value1.value != value2.value) {
      onChanged(selectedValue);
    }
  }

  useOnChangeNotifierNotified(notifier, selectValue, keys, listenableKeys);
}

/// Listens to a [ChangeNotifier] and selects and returns a value from it. When that value
/// differs from the previous build's value then it will mark the caller [HookWidget]
/// as needing a build.
R useChangeNotifierSelect<T extends ChangeNotifier, R>(T notifier, {required R Function(T) select}) {
  final stateValue = useState(select(notifier));

  useOnChangeNotifierValueChanged<T, R>(
    notifier,
    select: select,
    onChanged: (value) {
      stateValue.value = value;
    },
  );

  return stateValue.value;
}

/// Returns a [ChangeNotifier] which will only notify when the `select`ed value differs from it's previous value.
ChangeNotifier useSelectChangeNotifier<T extends Listenable, R>(
  T notifier, {
  required R Function(T notifier) select,
}) {
  final internalNotifier = useState(ChangeNotifier());

  useOnChangeNotifierValueChanged(
    notifier,
    select: (notifier) => select(notifier),
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    onChanged: (_) => internalNotifier.value.notifyListeners(),
  );

  return internalNotifier.value;
}

/// Mark the caller [HookWidget] as needing a build when the controller's text changes.
void rebuildWhenTextChanged(TextEditingController? controller) {
  if (controller == null) {
    return;
  }

  useChangeNotifierSelect<TextEditingController, String>(
    controller,
    select: (controller) => controller.value.text,
  );
}
