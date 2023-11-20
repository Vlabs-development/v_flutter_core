import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:v_core/src/widgets/reactive_text_field/autocomplete/raw_autocomplete_decoration.dart';
import 'package:v_core/v_core.dart';

class SearchDecoration<K, T> extends HookWidget {
  const SearchDecoration({
    required this.child,
    required this.onSelected,
    required this.onChangedDebounced,
    required this.onChanged,
    required this.listBuilder,
    required this.options,
    this.customBuilder,
    this.controller,
    this.customWidget,
    this.groupBuilder = defaultGroupAutocompleteBuilder,
    this.valueBuilder,
    this.debounceDuration = const Duration(milliseconds: 1000),
    this.selectedKey,
    this.maxDropdownHeight = 400,
    this.displayStringForOption = defaultStringForOption,
    this.offlineSearchContent,
    this.focusNode,
    required this.control,
    super.key,
  });

  final Widget child;
  final void Function(CompositeValue<K, T>?) onSelected;
  final void Function(TextEditingValue value) onChangedDebounced;
  final void Function(TextEditingValue value) onChanged;
  final String Function(T?) displayStringForOption;
  final String Function(T?)? offlineSearchContent;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final CompositeNode<K, T> options;
  final Duration debounceDuration;
  final double maxDropdownHeight;
  final K? selectedKey;
  final Widget Function(DepthCompositeGroup<K, T> node, bool isHighlighted) groupBuilder;
  final Widget Function(DepthCompositeValue<K, T> node, bool isSelected, bool isHighlighted, void Function() select)?
      valueBuilder;
  final Widget? Function(String value)? customBuilder;
  final Widget? customWidget;
  final FormControl<K> control;
  final Widget Function(ScrollController controller, List<Widget> children) listBuilder;

  CompositeValue<K, T>? get selectedValue => options.findByKey(selectedKey);

  @override
  Widget build(BuildContext context) {
    final inheritedFocusNode = context.requireExtension<ReactiveTextFieldBehavior>().focusNode;
    final effectiveFocusNode = focusNode ?? inheritedFocusNode ?? useFocusNode();
    final inheritedController = context.requireExtension<ReactiveTextFieldBehavior>().controller;
    final effectiveController = controller ?? inheritedController ?? useTextEditingController();

    final debounceOnChanged = useCancelableDebounceCallback(
      duration: debounceDuration,
      callback: () {
        if (effectiveFocusNode.hasFocus) {
          onChangedDebounced(effectiveController.value);
        }
      },
    );

    void effectiveOnChanged(TextEditingValue value) {
      if (!effectiveFocusNode.hasFocus) {
        return;
      }

      onChanged(value);

      if (value.text.isEmpty) {
        debounceOnChanged.cancel();
      } else {
        debounceOnChanged();
      }
    }

    void effectiveOnSelected(CompositeValue<K, T>? value) {
      onSelected(value);
      debounceOnChanged.cancel();
    }

    void applySelectedValueToField() {
      if (selectedValue != null) {
        effectiveController.setTextWithKeptSelection(displayStringForOption(selectedValue?.value));
        effectiveController.triggerValueChanged();
        control.patchValue(selectedKey);
      }
    }

    usePlainPostFrameEffect(
      () => applySelectedValueToField(),
      [selectedKey],
    );

    useOnChangeNotifierNotified(
      effectiveFocusNode,
      () {
        if (!effectiveFocusNode.hasFocus) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            applySelectedValueToField();
          });
        }
      },
      [options, selectedKey],
    );

    final offlineFilteredOptions = useMemoized2(
      () {
        if (offlineSearchContent == null) {
          return options;
        }

        return options.pruneTrunk(
          (node) => node.map(
            group: (group) => true,
            value: (value) {
              return offlineSearchContent?.call(value.value).toLowerCase().contains(effectiveController.text) ?? true;
            },
          ),
        );
      },
      [options.flattened.uniqueIdentifier, offlineSearchContent],
      [useSelectChangeNotifier(effectiveController, select: (it) => it.text)],
    );

    return RawAutocompleteDecoration<K, T>(
      control: control,
      controller: effectiveController,
      options: offlineFilteredOptions,
      onChanged: effectiveOnChanged,
      selectedKey: selectedKey,
      maxDropdownHeight: maxDropdownHeight,
      listBuilder: listBuilder,
      customWidget: customWidget,
      groupBuilder: groupBuilder,
      customBuilder: customBuilder,
      jumpToFirstMatch: null,
      valueBuilder: (node, isSelected, isHighlighted, select) {
        if (valueBuilder != null) {
          return valueBuilder!(node, isSelected, isHighlighted, select);
        }

        return defaultValueAutocompleteBuilder(
          node: node,
          isSelected: isSelected,
          isHighlighted: isHighlighted,
          select: select,
          displayStringForOption: displayStringForOption,
        );
      },
      onSelected: effectiveOnSelected,
      focusNode: effectiveFocusNode,
      child: child,
    );
  }
}
