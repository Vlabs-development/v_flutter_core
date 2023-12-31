import 'package:example/modules/input/showcase_field/showcase_form_field.dart';
import 'package:flutter/material.dart' hide Checkbox;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

Widget defaultListBuilder(ScrollController controller, List<Widget> children) {
  return Builder(
    builder: (context) {
      return Card(
        clipBehavior: Clip.none,
        margin: EdgeInsets.zero,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView(
          shrinkWrap: true,
          controller: controller,
          children: children,
        ),
      );
    },
  );
}

class ShowcaseAutocompleteField<K, T> extends HookWidget {
  ShowcaseAutocompleteField({
    required this.options,
    required this.onSelected,
    required this.selectedKey,
    this.groupBuilder = defaultGroupAutocompleteBuilder,
    this.valueBuilder,
    this.customBuilder,
    this.customWidget,
    this.focusNode,
    this.label = '',
    this.hint = '',
    this.maxDropdownHeight = 400.0,
    String Function(T?)? displayStringForOption,
    this.setValueWhenLabelMatches = true,
    this.validationMessages = const {},
    this.validators = const [],
    this.clearBehavior = CompositeNodeFieldClearBehavior.empty,
    this.showErrors = defaultShowErrors,
    this.decorate,
    super.key,
  })  : displayStringForOption = displayStringForOption ?? defaultStringForOption,
        assert(
          isNullableStringType<T>() || displayStringForOption != null,
          'When T ($T) is not a String? then displayStringForOption must be provided.',
        );

  final Widget Function(Widget field, FormControl<K> control)? decorate;
  final String Function(T? option) displayStringForOption;
  final CompositeGroup<K, T> options;
  final K? selectedKey;
  final String label;
  final String hint;
  final double maxDropdownHeight;
  final void Function(K? value) onSelected;
  final Widget Function(DepthCompositeGroup<K, T> node, bool isHighlighted) groupBuilder;
  final Widget Function(DepthCompositeValue<K, T> node, bool isSelected, bool isHighlighted, void Function() select)?
      valueBuilder;
  final Widget? Function(String value)? customBuilder;
  final CompositeNodeFieldClearBehavior clearBehavior;
  final Widget? customWidget;
  final FocusNode? focusNode;
  final bool setValueWhenLabelMatches;
  final List<Validator> validators;
  final ShowErrorsFunction<K> showErrors;
  final Map<String, String Function(Object)> validationMessages;

  @override
  Widget build(BuildContext context) {
    final control = useMemoized(
      () => FormControl<K>(
        validators: validators,
        value: selectedKey,
      ),
      [validators],
    );

    useEffect(
      () => control.valueChanges.listen((event) => onSelected(options.findByKey(event)?.key)).cancel,
      [options.hashCode],
    );

    usePlainEffect(
      () => control.patchValue(selectedKey),
      [selectedKey],
    );

    return ShowcaseAutocompleteFormField(
      formControl: control,
      options: options,
      displayStringForOption: displayStringForOption,
      label: label,
      hint: hint,
      clearBehavior: clearBehavior,
      groupBuilder: groupBuilder,
      valueBuilder: valueBuilder,
      focusNode: focusNode,
      customBuilder: customBuilder,
      customWidget: customWidget,
      maxDropdownHeight: maxDropdownHeight,
      setValueWhenLabelMatches: setValueWhenLabelMatches,
      validationMessages: validationMessages,
      showErrors: showErrors,
      decorate: decorate,
    );
  }
}

class ShowcaseAutocompleteFormField<K, T> extends HookWidget {
  ShowcaseAutocompleteFormField({
    required this.options,
    this.groupBuilder = defaultGroupAutocompleteBuilder,
    this.valueBuilder,
    this.customBuilder,
    this.customWidget,
    this.focusNode,
    this.label = '',
    this.hint = '',
    this.maxDropdownHeight = 400.0,
    String Function(T?)? displayStringForOption,
    this.formControl,
    this.formControlName,
    this.setValueWhenLabelMatches = false,
    this.clearBehavior = CompositeNodeFieldClearBehavior.none,
    this.showErrors = defaultShowErrors,
    this.validationMessages = const {},
    this.decorate,
    super.key,
  })  : displayStringForOption = displayStringForOption ?? defaultStringForOption,
        assert(
          isNullableStringType<T>() || displayStringForOption != null,
          'When T is not a String? then displayStringForOption must be provided.',
        ),
        assert(
          (formControlName != null && formControl == null) || (formControlName == null && formControl != null),
          'Must provide a formControlName or a formControl, but not both at the same time.',
        );

  final String Function(T? option) displayStringForOption;
  final CompositeGroup<K, T> options;
  final String label;
  final String hint;
  final double maxDropdownHeight;
  final bool setValueWhenLabelMatches;
  final Widget Function(DepthCompositeGroup<K, T> node, bool isHighlighted) groupBuilder;
  final Widget Function(DepthCompositeValue<K, T> node, bool isSelected, bool isHighlighted, void Function() select)?
      valueBuilder;
  final Widget? Function(String value)? customBuilder;
  final CompositeNodeFieldClearBehavior clearBehavior;
  final Widget? customWidget;
  final FocusNode? focusNode;
  final FormControl<K>? formControl;
  final ShowErrorsFunction<K> showErrors;
  final String? formControlName;
  final Widget Function(Widget field, FormControl<K> control)? decorate;
  final Map<String, String Function(Object)> validationMessages;

  @override
  Widget build(BuildContext context) {
    final control = () {
      if (formControl != null) {
        return formControl!;
      }

      final form = ReactiveForm.of(context);
      assert(form != null, 'parent form group not found!');
      final formGroup = form! as FormGroup;
      return formGroup.control(formControlName!) as FormControl<K>;
    }();

    final effectiveFocusNode = focusNode ?? useFocusNode();

    return ShowcaseFormField<K>(
      formControl: control,
      label: label,
      hint: hint,
      focusNode: effectiveFocusNode,
      validationMessages: validationMessages,
      showErrors: showErrors,
      valueAccessor: CompositeNodeValueAccessor(
        getDisplayString: displayStringForOption,
        options: options,
        setWhenViewMatchesDisplayValue: setValueWhenLabelMatches,
        clearBehavior: clearBehavior,
      ),
      decorate: (field, control) {
        final effectiveDecorate = decorate ?? identityDecorate;
        return effectiveDecorate(
          ApplyThemeExtension(
            theme: ReactiveTextFieldBehavior(
              onTapOutside: (pointerEvent) {
                effectiveFocusNode.unfocus();
              },
            ),
            child: HookBuilder(
              builder: (context) {
                return AutocompleteDecoration<K, T>(
                  control: control,
                  focusNode: effectiveFocusNode,
                  asYouTypeBehavior: AsYouTypeBehavior.jumpToFirstMatch,
                  displayStringForOption: displayStringForOption,
                  customBuilder: customBuilder,
                  groupBuilder: groupBuilder,
                  valueBuilder: valueBuilder,
                  customWidget: customWidget,
                  maxDropdownHeight: maxDropdownHeight,
                  listBuilder: defaultListBuilder,
                  selectedKey: control.value,
                  onSelected: (node) {
                    control.patchValue(node?.key);
                    control.markAsDirty();
                  },
                  depthLeftInset: 12,
                  options: options,
                  child: field,
                );
              },
            ),
          ),
          control,
        );
      },
    );
  }
}
