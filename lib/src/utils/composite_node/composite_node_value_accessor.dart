import 'package:reactive_forms/reactive_forms.dart';
import 'package:v_core/v_core.dart';

enum CompositeNodeFieldClearBehavior { none, empty, changed }

class CompositeNodeValueAccessor<K, T> extends ControlValueAccessor<K, String> {
  CompositeNodeValueAccessor({
    required this.getDisplayString,
    required this.options,
    required this.setWhenViewMatchesDisplayValue,
    this.clearBehavior = CompositeNodeFieldClearBehavior.none,
  });

  final String Function(T?) getDisplayString;
  final CompositeGroup<K, T> options;
  final bool setWhenViewMatchesDisplayValue;
  final CompositeNodeFieldClearBehavior clearBehavior;

  bool get clearWhenEmpty => clearBehavior == CompositeNodeFieldClearBehavior.empty;
  bool get clearWhenChanged => clearBehavior == CompositeNodeFieldClearBehavior.changed;

  @override
  String? modelToViewValue(K? modelValue) => getDisplayString(options.findByKey(modelValue)?.value);

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
