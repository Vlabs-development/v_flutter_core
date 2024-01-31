import 'package:reactive_forms/reactive_forms.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

enum CompositeNodeFieldClearBehavior { none, empty, changed }

class CompositeNodeValueAccessor<K, T> extends ControlValueAccessor<K, String> {
  CompositeNodeValueAccessor({
    required this.getDisplayString,
    required this.options,
    required this.setWhenViewMatchesDisplayValue,
    this.clearBehavior = CompositeNodeFieldClearBehavior.none,
  });

  final String Function(T) getDisplayString;
  final CompositeGroup<K, T> options;
  final bool setWhenViewMatchesDisplayValue;
  final CompositeNodeFieldClearBehavior clearBehavior;

  bool get clearWhenEmpty => clearBehavior == CompositeNodeFieldClearBehavior.empty;
  bool get clearWhenChanged => clearBehavior == CompositeNodeFieldClearBehavior.changed;

  @override
  String? modelToViewValue(K? modelValue) {
    final value = options.findByKey(modelValue)?.value;
    if (value != null) {
      return getDisplayString(value);
    }
    return null;
  }

  @override
  K? viewToModelValue(String? viewValue) {
    final foundModel = options.findByDisplayValue(viewValue, getDisplayString)?.key;
    final isEmpty = viewValue?.isEmpty ?? true;

    if (clearWhenEmpty && isEmpty) {
      return null;
    }

    if (foundModel == null && clearWhenChanged) {
      return null;
    }

    if (control?.value != foundModel && foundModel != null && setWhenViewMatchesDisplayValue) {
      return foundModel;
    }

    return control?.value;
  }
}
