import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

void Function(Set<T> values)? convertToMultiOnChanged<T>(void Function(T? value)? onChanged) {
  if (onChanged == null) {
    return null;
  }

  return (Set<T> values) {
    if (values.isNotEmpty) {
      onChanged(values.first);
    } else {
      onChanged(null);
    }
  };
}

void Function(T? values)? convertToSingleOnChanged<T>(void Function(Set<T> value)? onChanged) {
  if (onChanged == null) {
    return null;
  }

  return (T? value) {
    if (value != null) {
      onChanged({value});
    } else {
      onChanged({});
    }
  };
}

class CascadingDropdown<K, T> extends HookWidget {
  CascadingDropdown.multi({
    required this.builder,
    required this.options,
    this.maxHeight,
    this.selectedKeys = const {},
    void Function(Set<K> values)? onChanged,
    this.alignStart = true,
    this.isExpanded = false,
    Widget Function(T? it) displayWidgetForOption = defaultWidgetForOption,
    bool closeOnActivate = false,
    bool showLeading = true,
    Widget Function(CompositeGroup<K, T>? parentNode, CompositeValue<K, T> compositeValue, double width)? valueBuilder,
    Widget Function(
      CompositeGroup<K, T>? parentNode,
      CompositeGroup<K, T> compositeGroup,
      List<Widget> mappedChildren,
      double width,
    )? groupBuilder,
    super.key,
  })  : valueBuilder = valueBuilder ??
            _defaultValueBuilder(
              showLeading: showLeading,
              allowMultiple: true,
              selectedKeys: selectedKeys,
              closeOnActivate: closeOnActivate,
              onChanged: onChanged,
              displayWidgetForOption: displayWidgetForOption,
            ),
        groupBuilder = groupBuilder ?? _defaultGroupBuilder(),
        allowMultiple = true;

  CascadingDropdown.single({
    required this.builder,
    required this.options,
    this.maxHeight,
    K? selectedKey,
    void Function(K? value)? onChanged,
    this.alignStart = true,
    this.isExpanded = false,
    Widget Function(T? it) displayWidgetForOption = defaultWidgetForOption,
    bool closeOnActivate = true,
    bool showLeading = true,
    Widget Function(CompositeGroup<K, T>?, CompositeValue<K, T>, double width)? valueBuilder,
    Widget Function(CompositeGroup<K, T>?, CompositeGroup<K, T>, List<Widget>, double width)? groupBuilder,
    super.key,
  })  : valueBuilder = valueBuilder ??
            _defaultValueBuilder(
              showLeading: showLeading,
              closeOnActivate: closeOnActivate,
              allowMultiple: false,
              selectedKeys: {
                ...{selectedKey}.whereType<K>(),
              },
              onChanged: convertToMultiOnChanged(onChanged),
              displayWidgetForOption: displayWidgetForOption,
            ),
        groupBuilder = groupBuilder ?? _defaultGroupBuilder(),
        selectedKeys = {
          ...{selectedKey}.whereType<K>(),
        },
        allowMultiple = false;

  final Widget Function(MenuController controller) builder;
  final CompositeGroup<K, T> options;
  final Set<K> selectedKeys;
  final double? maxHeight;
  final Widget Function(CompositeGroup<K, T>? parentNode, CompositeValue<K, T> compositeValue, double width)
      valueBuilder;
  final Widget Function(
    CompositeGroup<K, T>? parentNode,
    CompositeGroup<K, T> compositeGroup,
    List<Widget> mappedChildren,
    double width,
  ) groupBuilder;
  final bool alignStart;
  final bool isExpanded;
  final bool allowMultiple;

  @override
  Widget build(BuildContext context) {
    List<Widget> getMenuItems({required bool autoExpand, double width = double.infinity}) {
      final selectedKey = selectedKeys.firstOrNull;
      List<CompositeNode<K, T>> path = [];
      if (selectedKey != null) {
        path = options.pathToNode(selectedKey) ?? [];
      }

      return [
        ...options
            .transform<Widget>(
              mapValue: (parentNode, compositeValue) {
                final valueInPath = path.whereType<CompositeValue<K, T>>().map((e) => e.key).contains(
                      compositeValue.key,
                    );
                return StepFocus(
                  enabled: valueInPath && autoExpand,
                  child: valueBuilder(parentNode, compositeValue, width),
                );
              },
              mapGroup: (parentNode, compositeGroup, transformedChildren) {
                final groupInPath = path.whereType<CompositeGroup<K, T>>().map((e) => e.label).contains(
                      compositeGroup.label,
                    );
                return StepFocus(
                  enabled: groupInPath && autoExpand,
                  child: groupBuilder(parentNode, compositeGroup, transformedChildren, width),
                );
              },
            )
            .map<Widget>((it) => Directionality(textDirection: TextDirection.ltr, child: Container(child: it)))
            .mapIndexed((index, it) => index == 0 && selectedKey == null ? StepFocus(child: it) : it),
      ];
    }

    final triggerRebuild = useRebuild();
    final autoExpand = useState(true);

    return Directionality(
      textDirection: alignStart ? TextDirection.ltr : TextDirection.rtl,
      child: HookBuilder(
        builder: (context) {
          final anchorWidth = useState(0.0);
          return SizeReporter(
            onChange: (size, offset) => anchorWidth.value = size.width,
            child: AlwaysScrollbar(
              child: MenuAnchor(
                crossAxisUnconstrained: false,
                style: MenuStyle(
                  maximumSize: MaterialStatePropertyAll(
                    Size(
                      isExpanded ? anchorWidth.value : double.infinity,
                      maxHeight ?? double.infinity,
                    ),
                  ),
                ),
                onClose: () {
                  triggerRebuild();
                  autoExpand.value = true;
                },
                onOpen: () async {
                  triggerRebuild();
                  await Future<void>.delayed(const Duration(milliseconds: 500));
                  autoExpand.value = false;
                },
                builder: (context, controller, child) {
                  return Directionality(
                    textDirection: TextDirection.ltr,
                    child: Container(child: builder(controller)),
                  );
                },
                menuChildren: [
                  if (isExpanded) SizedBox(width: anchorWidth.value),
                  ...getMenuItems(
                    autoExpand: autoExpand.value,
                    width: isExpanded ? anchorWidth.value : double.infinity,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

extension MenuControllerX on MenuController {
  void toggle() {
    if (isOpen) {
      close();
    } else {
      open();
    }
  }
}

extension SetX<K> on Set<K> {
  Set<K> toggling(K value) {
    if (contains(value)) {
      return Set.from(this)..remove(value);
    } else {
      return Set.from(this)..add(value);
    }
  }
}

Widget Function(CompositeGroup<K, T>?, CompositeValue<K, T>, double width) _defaultValueBuilder<K, T>({
  required bool showLeading,
  required bool allowMultiple,
  required bool closeOnActivate,
  required Set<K> selectedKeys,
  required void Function(Set<K> values)? onChanged,
  required Widget Function(T? option) displayWidgetForOption,
}) {
  return (parent, compositeValue, width) {
    final isSelected = selectedKeys.contains(compositeValue.key);
    final disabled = onChanged == null;

    void effectiveOnChanged(bool? value) {
      if (allowMultiple) {
        onChanged?.call(selectedKeys.toggling(compositeValue.key));
      } else {
        onChanged?.call({compositeValue.key});
      }
    }

    Color effectiveColor(BuildContext context) {
      final theme = context.requireExtension<CascadingDropdownTheme>();

      if (disabled) {
        return theme.disabledColor;
      }
      if (isSelected) {
        return theme.selectedColor;
      }

      return theme.color;
    }

    Widget effectiveLeading() {
      if (!showLeading) {
        return const SizedBox();
      }

      if (allowMultiple) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Checkbox(
            value: isSelected,
            onChanged: effectiveOnChanged,
          ),
        );
      } else {
        return Radio(
          value: compositeValue.key,
          groupValue: selectedKeys.singleOrNull,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          onChanged: (_) {},
        );
      }
    }

    final leftPadding = () {
      if (showLeading) {
        if (allowMultiple) {
          return 16.0;
        } else {
          return 8.0;
        }
      } else {
        return 16.0;
      }
    }();

    return Builder(
      builder: (context) {
        return MenuItemButton(
          style: ButtonStyle(
            padding: MaterialStatePropertyAll(EdgeInsets.only(left: leftPadding, right: 16)),
          ),
          closeOnActivate: closeOnActivate,
          onPressed: () => effectiveOnChanged(!isSelected),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Focus(
                canRequestFocus: false,
                child: AbsorbPointer(child: effectiveLeading()),
              ),
              Flexible(
                child: DefaultTextStyle(
                  style: TextStyle(color: effectiveColor(context)),
                  child: displayWidgetForOption(compositeValue.value),
                ),
                // child: Text(
                //   displayWidgetForOption(compositeValue.value),
                //   style: TextStyle(color: effectiveColor(context)),
                // ),
              ),
            ],
          ),
        );
      },
    );
  };
}

Widget Function(CompositeGroup<K, T>?, CompositeGroup<K, T>, List<Widget>, double width) _defaultGroupBuilder<K, T>() {
  return (parent, compositeGroup, transformedChildren, width) {
    return SubmenuButton(
      menuChildren: transformedChildren,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(compositeGroup.label),
      ),
    );
  };
}
