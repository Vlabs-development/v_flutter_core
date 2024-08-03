import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

Widget defaultGroupAutocompleteBuilder(DepthCompositeGroup<dynamic, dynamic> node, bool isHighlighted) {
  return Builder(
    builder: (context) {
      return ListTile(
        title: Padding(
          padding: EdgeInsets.only(left: node.depth * 10),
          child: Text(
            node.group.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        selected: isHighlighted,
      );
    },
  );
}

Widget defaultValueAutocompleteBuilder<K, T>({
  required DepthCompositeValue<K, T> node,
  required bool isSelected,
  required bool isHighlighted,
  required void Function() select,
  required String Function(T) displayStringForOption,
}) =>
    Builder(
      builder: (context) {
        return Material(
          type: MaterialType.transparency,
          child: ListTile(
            title: Padding(
              padding: EdgeInsets.only(left: node.depth * 10),
              child: Text(displayStringForOption(node.value.value)),
            ),
            selected: isHighlighted || isSelected,
            onTap: () => select(),
          ),
        );
      },
    );

extension DepthCompositeNodeListX<K, T> on List<DepthCompositeNode<K, T>> {
  int get uniqueIdentifier {
    final it = map((e) => e.node.map(value: (v) => v.key, group: (g) => g.label)).join().hashCode;
    return it;
  }

  int? maybeIndexOf({required K? key}) {
    final index = indexWhere(
      (it) => it.node.map(
        value: (value) => value.key == key,
        group: (_) => false,
      ),
    );

    if (index == -1) {
      return null;
    }

    return index;
  }

  K? keyAt({required int index}) {
    if (index > length - 1) {
      return null;
    }

    final node = this[index].node;
    return node.map(
      group: (_) => null,
      value: (value) => value.key,
    );
  }
}

extension on int {
  int moduloRange({required int min, required int max}) {
    if (this < min) {
      return max - (min - this) + 1;
    }
    if (this > max) {
      return min + (this - max) - 1;
    }

    return this;
  }
}

class RawAutocompleteDecoration<K, T> extends HookWidget {
  const RawAutocompleteDecoration({
    required this.child,
    required this.onSelected,
    required this.options,
    required this.groupBuilder,
    required this.valueBuilder,
    required this.listBuilder,
    required this.control,
    this.jumpToFirstMatch,
    this.optionsViewOpenDirection = OptionsViewOpenDirection.down,
    this.customBuilder,
    this.customWidget,
    this.onChanged,
    this.selectedKey,
    this.focusNode,
    this.controller,
    this.maxDropdownHeight = 400.0,
    super.key,
  });

  final Widget child;
  final K? selectedKey;
  final void Function(CompositeValue<K, T>) onSelected;
  final void Function(TextEditingValue value)? onChanged;
  final CompositeNode<K, T> options;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final double maxDropdownHeight;
  final Widget? Function(String value)? customBuilder;
  final Widget? customWidget;
  final String Function(T)? jumpToFirstMatch;
  final OptionsViewOpenDirection optionsViewOpenDirection;
  final Widget Function(DepthCompositeGroup<K, T> node, bool isHighlighted) groupBuilder;
  final Widget Function(
    DepthCompositeValue<K, T> node,
    bool isSelected,
    bool isHighlighted,
    void Function() select,
  ) valueBuilder;
  final Widget Function(ScrollController controller, List<Widget> children) listBuilder;
  final FormControl<K> control;

  @override
  Widget build(BuildContext context) {
    final optionsList = options.flattened;
    final inheritedController = context.requireExtension<ReactiveTextFieldBehavior>().controller;
    final effectiveController = controller ?? inheritedController ?? useTextEditingController();

    final effectiveFocusNode = focusNode ?? useFocusNode();
    final fieldWidth = useValueNotifier(0.0);
    final availableSpaceBelow = useValueNotifier<double?>(null);

    final scrollOffset = useValueNotifier(0.0);
    final highlightedIndex = useValueNotifier(-1);
    final highlightedKey = useValueNotifier<K?>(selectedKey);

    DepthCompositeNode<K, T>? currentlyHighlightedNode() {
      if (optionsList.isEmpty) {
        return null;
      }
      final indexOf = optionsList.maybeIndexOf(key: highlightedKey.value);

      if (indexOf == null) {
        return null;
      }

      return optionsList[indexOf];
    }

    final isMounted = useIsMounted();

    void highlightIndex(int index) {
      if (!isMounted()) {
        return;
      }

      highlightedIndex.value = index;
      final key = optionsList.keyAt(index: highlightedIndex.value);
      highlightedKey.value = key;
    }

    void clearHighlight() {
      highlightedIndex.value = -1;
      highlightedKey.value = null;
    }

    void effectiveOnSelected([CompositeNode<K, T>? node]) {
      final paramNode = node as CompositeValue<K, T>?;
      if (paramNode != null) {
        onSelected(paramNode);
      } else {
        final implicitNode = currentlyHighlightedNode()!.node as CompositeValue<K, T>;
        onSelected(implicitNode);
      }
      clearHighlight();
    }

    void moveSelectionUp({int delta = 1}) {
      if (optionsList.isEmpty) {
        return;
      }

      final newIndex = (highlightedIndex.value - delta).moduloRange(
        min: 0,
        max: optionsList.length - 1,
      );
      if (optionsList[newIndex].node.isGroup) {
        return moveSelectionUp(delta: delta + 1);
      }

      highlightIndex(newIndex);
    }

    void moveSelectionDown({int delta = 1}) {
      if (optionsList.isEmpty) {
        return;
      }

      final newIndex = (highlightedIndex.value + delta).moduloRange(
        min: 0,
        max: optionsList.length - 1,
      );
      if (optionsList[newIndex].node.isGroup) {
        return moveSelectionDown(delta: delta + 1);
      }

      highlightIndex(newIndex);
    }

    usePlainPostFrameEffect(
      () => effectiveController.triggerValueChanged(),
      [optionsList.uniqueIdentifier],
    );

    final globalKey = useGlobalKey();

    return SizeReporter(
      onChange: (size, offset) {
        fieldWidth.value = size.width;
        availableSpaceBelow.value = MediaQuery.sizeOf(context).height - ((offset.dy) + size.height);
      },
      child: HookBuilder(
        builder: (context) {
          return ApplyThemeExtension(
            theme: ReactiveTextFieldBehavior(
              controller: effectiveController,
              focusNode: effectiveFocusNode,
              onChanged: (control) {
                onChanged?.call(effectiveController.value);
              }.whenNotNull(onChanged),
              onSubmitted: (control) {
                effectiveOnSelected();
              },
            ),
            child: RawAutocomplete<DepthCompositeNode<K, T>>(
              textEditingController: effectiveController,
              optionsViewOpenDirection: optionsViewOpenDirection,
              focusNode: effectiveFocusNode,
              fieldViewBuilder: (context, _, __, onFieldSubmitted) {
                return HookBuilder(
                  builder: (context) {
                    return CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.arrowUp): () => moveSelectionUp(),
                        const SingleActivator(LogicalKeyboardKey.arrowDown): () => moveSelectionDown(),
                      },
                      child: child,
                    );
                  },
                );
              },
              optionsBuilder: (value) {
                if (customWidget != null || customBuilder?.call(value.text) != null) {
                  return [DepthCompositeNode(node: CompositeGroup.empty(), depth: 0)];
                }

                return optionsList;
              },
              onSelected: (optionNode) {
                final option = optionNode.node as CompositeValue<K, T>?;
                if (option == null) {
                  throw 'Selected option is not a CompositeNode<$T> node.';
                }
                effectiveOnSelected();
              },
              optionsViewBuilder: (context, _, optionsList) {
                final optionList = optionsList.toList();
                return Entry(
                  key: globalKey,
                  yOffset: -8,
                  opacity: 0,
                  child: HookBuilder(
                    builder: (context) {
                      final scrollController = useScrollController();

                      void highlightSelectedKeyIfCanBeFound() {
                        final maybeSelectedIndex = optionList.maybeIndexOf(key: selectedKey);
                        if (maybeSelectedIndex != null) {
                          highlightIndex(maybeSelectedIndex);
                        }
                      }

                      int moduloIndexAndSkipGroup(int index, {int delta = 0}) {
                        if (optionList.isEmpty) {
                          return 0;
                        }

                        final rotatedIndex = (index + delta).moduloRange(
                          min: 0,
                          max: optionList.length - 1,
                        );
                        if (rotatedIndex < optionList.length && optionList[rotatedIndex].node.isGroup) {
                          return moduloIndexAndSkipGroup(index, delta: delta + 1);
                        }

                        return rotatedIndex;
                      }

                      void highlightFirstValue() => highlightIndex(moduloIndexAndSkipGroup(0));

                      void jumpToHighlightedIndex(int index) {
                        if (scrollController.hasClients) {
                          final extentBefore = scrollController.position.extentBefore;
                          final extentInside = scrollController.position.extentInside;
                          final extentAfter = scrollController.position.extentAfter;

                          final height = extentBefore + extentInside + extentAfter;

                          final roughItemHeight = height / optionsList.length;
                          final itemStart = roughItemHeight * index;
                          final itemEnd = itemStart + roughItemHeight;

                          double jumpTo = scrollController.offset;
                          if (itemStart < extentBefore) {
                            jumpTo = itemStart;
                          } else if (itemEnd > extentBefore + extentInside) {
                            jumpTo = itemEnd - extentInside;
                          }
                          scrollController.jumpTo(jumpTo);
                        }
                      }

                      final index = useValueListenable(highlightedIndex);
                      usePlainPostFrameEffect(
                        () {
                          if (index >= 0) {
                            jumpToHighlightedIndex(index);
                          }
                        },
                        [index],
                      );

                      usePlainPostFrameEffect(
                        () {
                          if (highlightedIndex.value == -1) {
                            if (selectedKey != null) {
                              highlightSelectedKeyIfCanBeFound();
                            } else {
                              highlightFirstValue();
                            }
                          }
                        },
                        [selectedKey, optionList.uniqueIdentifier],
                      );

                      usePlainPostFrameEffect(
                        () {
                          if (highlightedIndex.value != -1) {
                            if (selectedKey != null) {
                              highlightSelectedKeyIfCanBeFound();
                            }
                          }
                        },
                        [selectedKey],
                      );

                      usePlainPostFrameEffect(
                        () {
                          if (highlightedKey.value != null) {
                            final indexOfHighlight = optionList.maybeIndexOf(key: highlightedKey.value);
                            if (indexOfHighlight != null) {
                              highlightIndex(indexOfHighlight);
                              return;
                            }
                          }
                          final indexOfSelected = optionList.maybeIndexOf(key: selectedKey);
                          if (indexOfSelected != null) {
                            highlightSelectedKeyIfCanBeFound();
                          } else {
                            highlightFirstValue();
                          }
                        },
                        [selectedKey, optionList.uniqueIdentifier],
                        [highlightedIndex, highlightedKey, effectiveController],
                      );

                      usePlainPostFrameEffect(() {
                        if (scrollController.hasClients) {
                          if (scrollOffset.value > scrollController.position.maxScrollExtent) {
                            scrollController.jumpTo(scrollController.position.maxScrollExtent);
                          }
                        }
                      });

                      useOnChangeNotifierNotified(effectiveFocusNode, () {
                        if (!effectiveFocusNode.hasFocus) {
                          clearHighlight();
                        }
                      });

                      useValueListener(
                        customWidget.hashCode,
                        () => effectiveController.triggerValueChanged(),
                        fireImmediately: false,
                      );

                      useOnChangeNotifierNotified(
                        scrollController,
                        () {
                          if (scrollController.hasClients) {
                            scrollOffset.value = scrollController.offset;
                          }
                        },
                        [],
                      );

                      void onControllerTextChange(String value) {
                        if (jumpToFirstMatch == null) {
                          return;
                        }

                        final firstKey = (options
                                .pruneByLabel(jumpToFirstMatch!, value, behavior: PruneByLabelBehavior.startsWith)
                                .flattened
                                .firstWhereOrNull((element) => element.node is CompositeValue<K, T>)
                                ?.node as CompositeValue<K, T>?)
                            ?.key;

                        final index = optionList.maybeIndexOf(key: firstKey);
                        if (index != null) {
                          highlightIndex(index);
                        }
                      }

                      useOnChangeNotifierValueChanged(
                        effectiveController,
                        select: (controller) => controller.text,
                        onChanged: onControllerTextChange,
                      );

                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          type: MaterialType.transparency,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: math.min(maxDropdownHeight, availableSpaceBelow.value ?? maxDropdownHeight),
                              maxWidth: useValueListenable(fieldWidth),
                            ),
                            child: HookBuilder(
                              builder: (context) {
                                if (customWidget != null) {
                                  return customWidget!;
                                }

                                final customBuiltWidget = customBuilder?.call(effectiveController.text);
                                if (customBuiltWidget != null) {
                                  return customBuiltWidget;
                                }

                                final itemWidgets = optionList.mapIndexed((index, item) {
                                  final isHighlightedOption = useValueListenable(highlightedIndex) == index;
                                  final node = optionList[index];

                                  return node.map(
                                    group: (group) {
                                      return groupBuilder(group, isHighlightedOption);
                                    },
                                    value: (value) {
                                      final isSelectedOption = selectedKey == value.value.key;

                                      return valueBuilder(
                                        value,
                                        isSelectedOption,
                                        isHighlightedOption,
                                        () {
                                          effectiveOnSelected(node.node);
                                          effectiveFocusNode.unfocus();
                                        },
                                      );
                                    },
                                  );
                                });

                                return listBuilder(scrollController, itemWidgets.toList());
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
