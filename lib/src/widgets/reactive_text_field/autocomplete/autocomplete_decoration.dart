import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

enum AsYouTypeBehavior { filter, jumpToFirstMatch }

extension AsYouTypeBehaviorX on AsYouTypeBehavior {
  bool get isFilter {
    return switch (this) {
      AsYouTypeBehavior.filter => true,
      _ => false,
    };
  }

  bool get isJumpToFirstMatch {
    return switch (this) {
      AsYouTypeBehavior.jumpToFirstMatch => true,
      _ => false,
    };
  }
}

class AutocompleteDecoration<K, T> extends HookWidget {
  const AutocompleteDecoration({
    required this.child,
    required this.options,
    required this.onSelected,
    required this.displayStringForOption,
    required this.listBuilder,
    required this.control,
    this.groupBuilder = defaultGroupAutocompleteBuilder,
    this.optionsViewOpenDirection = OptionsViewOpenDirection.down,
    this.valueBuilder,
    this.customBuilder,
    this.customWidget,
    this.selectedKey,
    this.focusNode,
    this.depthLeftInset = 0.0,
    this.maxDropdownHeight = 400.0,
    this.asYouTypeBehavior = AsYouTypeBehavior.filter,
    super.key,
  });

  final Widget child;
  final CompositeNode<K, T> options;
  final K? selectedKey;
  final void Function(CompositeValue<K, T>?) onSelected;
  final String Function(T) displayStringForOption;
  final double depthLeftInset;
  final double maxDropdownHeight;
  final AsYouTypeBehavior asYouTypeBehavior;
  final FocusNode? focusNode;
  final Widget Function(DepthCompositeGroup<K, T> node, bool isHighlighted) groupBuilder;
  final Widget Function(DepthCompositeValue<K, T> node, bool isSelected, bool isHighlighted, void Function() select)?
      valueBuilder;
  final Widget? Function(String value)? customBuilder;
  final Widget? customWidget;
  final FormControl<K> control;
  final Widget Function(ScrollController controller, List<Widget> children) listBuilder;
  final OptionsViewOpenDirection optionsViewOpenDirection;

  CompositeValue<K, T>? get selectedValue => options.findByKey(selectedKey);

  @override
  Widget build(BuildContext context) {
    final inheritedFocusNode = context.requireExtension<ReactiveTextFieldBehavior>().focusNode;
    final effectiveFocusNode = focusNode ?? inheritedFocusNode ?? useFocusNode();

    final inheritedController = context.requireExtension<ReactiveTextFieldBehavior>().controller;
    final effectiveController = inheritedController ?? useTextEditingController();

    final hasFinishedSelection = useValueNotifier(false);
    final isMounted = useIsMounted();

    void onSelectedKeyChange() {
      final innerSelectedValue = selectedValue?.value;
      if (selectedValue != null && innerSelectedValue != null) {
        final displayValue = displayStringForOption(innerSelectedValue);
        control.patchValue(selectedKey);
        if (effectiveController.isEntirelySelected) {
          effectiveController.value = effectiveController.value.copyWith(
            text: displayValue,
            selection: TextSelection(baseOffset: 0, extentOffset: displayValue.length),
          );
        } else {
          effectiveController.setTextWithKeptSelection(displayValue);
          effectiveController.triggerValueChanged();
        }
      } else {
        if (!effectiveFocusNode.hasFocus) {
          effectiveController.clear();
          control.value = null;
        }
      }
    }

    void clearAfterFocusLostIfSelectedValueIsNull() {
      if (isMounted()) {
        if (selectedValue == null) {
          effectiveController.clear();
          control.value = null;
        } else {
          onSelectedKeyChange();
        }
      }
    }

    usePlainPostFrameEffect(
      () => onSelectedKeyChange(),
      [selectedKey],
    );

    useOnChangeNotifierNotified(
      effectiveFocusNode,
      () {
        if (effectiveFocusNode.hasFocus) {
          effectiveController.selectAll();
          hasFinishedSelection.value = true;
        } else {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (isMounted()) {
              clearAfterFocusLostIfSelectedValueIsNull();
              hasFinishedSelection.value = false;
            }
          });
        }
      },
      [options, selectedKey],
    );

    final filteredOptions = useMemoized2(
      () {
        final selection = effectiveController.selection;
        if (effectiveController.isEntirelySelected || !selection.isValid || !hasFinishedSelection.value) {
          return options;
        } else {
          return options.pruneByLabel(displayStringForOption, effectiveController.text);
        }
      },
      [
        options.flattened.uniqueIdentifier,
      ],
      [
        useSelectChangeNotifier(effectiveController, select: (it) => it.selection),
      ],
    );

    return RawAutocompleteDecoration<K, T>(
      control: control,
      selectedKey: selectedKey,
      options: asYouTypeBehavior.isFilter ? filteredOptions : options,
      onSelected: onSelected,
      maxDropdownHeight: maxDropdownHeight,
      customBuilder: customBuilder,
      customWidget: customWidget,
      listBuilder: listBuilder,
      focusNode: effectiveFocusNode,
      controller: effectiveController,
      groupBuilder: groupBuilder,
      optionsViewOpenDirection: optionsViewOpenDirection,
      jumpToFirstMatch: asYouTypeBehavior.isJumpToFirstMatch ? displayStringForOption : null,
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
      child: child,
    );
  }
}

extension on TextEditingController {
  void selectAll() {
    selection = TextSelection(
      baseOffset: 0,
      extentOffset: text.length,
    );
  }

  bool get isEntirelySelected => (selection.end - selection.start) == text.length;
}
