import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:v_flutter_core/src/utils/composite_node/depth_composite_node.dart';

Widget defaultWidgetForOption(Object? it) {
  return Text(defaultStringForOption(it));
}

String defaultStringForOption(Object? it) {
  if (it == null) {
    return '';
  }
  if (it is String?) {
    return it as String? ?? '';
  }

  return it.toString();
}

abstract class CompositeNode<K, T> {
  bool get isEmpty;
  bool get isGroup;
  bool get isLeaf;
}

class CompositeGroup<K, T> implements CompositeNode<K, T> {
  CompositeGroup({
    required this.label,
    required this.nodes,
  });
  CompositeGroup.root({
    required this.nodes,
  }) : label = "";
  CompositeGroup.empty()
      : label = "",
        nodes = {};

  factory CompositeGroup.map(Map<K, T> map, {String? label = ''}) => map.toCompositeNode(label: label);

  factory CompositeGroup.fromKeys(Iterable<K> list, T Function(K item) build) =>
      Map.fromEntries(list.map((e) => MapEntry(e, build(e)))).asCompositeNode;

  factory CompositeGroup.fromValues(Iterable<T> list, K Function(T item) build) =>
      Map.fromEntries(list.map((e) => MapEntry(build(e), e))).asCompositeNode;

  factory CompositeGroup.indexed(Iterable<K> list, MapEntry<K, T> Function(int index, K item) build) =>
      Map.fromEntries(list.mapIndexed((index, e) => build(index, e))).asCompositeNode;

  factory CompositeGroup.fromEntries(Iterable<MapEntry<K, T>> entries) =>
      Map.fromEntries(entries).toCompositeNode(label: 'cica');

  static CompositeGroup<T, T> fromList<T>(Iterable<T> items) => CompositeGroup.map(
        Map.fromEntries(items.map((e) => MapEntry(e, e))),
      );

  final Set<CompositeNode<K, T>> nodes;

  String label;

  void add(CompositeNode<K, T> node) => this.nodes.add(node);
  void addAll(Set<CompositeNode<K, T>> nodes) => this.nodes.addAll(nodes);

  @override
  bool get isEmpty => nodes.isEmpty;

  @override
  bool get isLeaf => false;

  @override
  bool get isGroup => true;

  @override
  String toString() => 'CompositeGroup(nodes: $nodes)';
}

class CompositeValue<K, T> implements CompositeNode<K, T> {
  CompositeValue({
    required this.key,
    required this.value,
  });

  static CompositeValue<String, String> plain(String value) => CompositeValue<String, String>(key: value, value: value);

  K key;
  T value;

  @override
  bool get isEmpty => false;

  @override
  bool get isLeaf => true;

  @override
  bool get isGroup => false;

  @override
  String toString() => 'CompositeValue(value: $value)';
}

extension CompositeNodeListExtensions<V> on List<V> {
  CompositeGroup<V, V> get asCompositeNode {
    final result = CompositeGroup<V, V>.root(nodes: <CompositeNode<V, V>>{});

    for (final item in this) {
      result.add(CompositeValue(key: item, value: item));
    }

    return result;
  }
}

extension MapX<K, V> on Map<K, V> {
  CompositeGroup<K, V> toCompositeNode({String? label}) {
    final result = CompositeGroup<K, V>(label: label ?? '', nodes: <CompositeNode<K, V>>{});

    for (final entry in entries) {
      final key = entry.key;
      final value = entry.value;

      final compositeValue = CompositeValue(key: key, value: value);
      result.add(compositeValue);
    }

    return result;
  }

  CompositeGroup<K, V> get asCompositeNode {
    final result = CompositeGroup<K, V>.root(nodes: <CompositeNode<K, V>>{});

    for (final entry in entries) {
      final key = entry.key;
      final value = entry.value;

      final compositeValue = CompositeValue(key: key, value: value);
      result.add(compositeValue);
    }

    return result;
  }
}

extension CompositeNodeX<K, T> on CompositeNode<K, T> {
  R when<R>({
    required R Function(T value) value,
    required R Function(String label, List<CompositeNode<K, T>> items) group,
  }) {
    if (this is CompositeGroup<K, T>) {
      final groupNode = this as CompositeGroup<K, T>;
      return group(groupNode.label, groupNode.nodes.toList());
    } else {
      final valueNode = this as CompositeValue<K, T>;
      return value(valueNode.value);
    }
  }

  R map<R>({
    required R Function(CompositeGroup<K, T> group) group,
    required R Function(CompositeValue<K, T> value) value,
  }) {
    if (this is CompositeGroup<K, T>) {
      final groupNode = this as CompositeGroup<K, T>;
      return group(groupNode);
    } else {
      final valueNode = this as CompositeValue<K, T>;
      return value(valueNode);
    }
  }

  CompositeNode<K, T> pruneTrunk(bool Function(CompositeNode<K, T> node) predicate) {
    final maybeRootLabel = map(value: (v) => null, group: (g) => g.label) ?? '';
    final prunedTree = pruneBranch(predicate);
    return prunedTree ?? CompositeGroup(label: maybeRootLabel, nodes: {});
  }

  CompositeNode<K, T>? pruneBranch(bool Function(CompositeNode<K, T> node) predicate) {
    return map<CompositeNode<K, T>?>(
      group: (group) {
        if (!predicate(group)) {
          return null;
        }

        final remainingItems = group.nodes.map((item) => item.pruneBranch(predicate)).whereNotNull().toList();
        if (remainingItems.isEmpty) {
          return null;
        } else {
          return CompositeGroup(label: group.label, nodes: Set.from(remainingItems));
        }
      },
      value: (value) {
        if (predicate(this)) {
          return this;
        } else {
          return null;
        }
      },
    );
  }

  List<CompositeNode<K, T>>? pathToNode(K? key) {
    if (isEmpty) {
      return null;
    }

    if (isLeaf) {
      if (this is CompositeValue<K, T>) {
        final value = this as CompositeValue<K, T>;
        if (value.key == key) {
          return [this];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }

    if (isGroup) {
      for (final node in (this as CompositeGroup<K, T>).nodes) {
        final path = node.pathToNode(key);
        if (path != null) {
          return [this, ...path];
        }
      }
    }

    return null;
  }

  R transform<R>({
    CompositeGroup<K, T>? parentNode,
    required R Function(
      CompositeGroup<K, T>? parentNode,
      CompositeValue<K, T> compositeValue,
    ) mapValue,
    required R Function(
      CompositeGroup<K, T>? parentNode,
      CompositeGroup<K, T> compositeGroup,
      List<R> transformedChildren,
    ) mapGroup,
  }) =>
      map(
        value: (value) => mapValue(parentNode, value),
        group: (group) => mapGroup(
          parentNode,
          group,
          group.nodes.map((it) => it.transform(parentNode: group, mapValue: mapValue, mapGroup: mapGroup)).toList(),
        ),
      );
}

extension MapCompositeGroup<K, T> on CompositeGroup<K, T> {
  List<R> transform<R>({
    CompositeGroup<K, T>? parentNode,
    required R Function(
      CompositeGroup<K, T>? parentNode,
      CompositeValue<K, T> compositeValue,
    ) mapValue,
    required R Function(
      CompositeGroup<K, T>? parentNode,
      CompositeGroup<K, T> compositeGroup,
      List<R> transformedChildren,
    ) mapGroup,
  }) =>
      nodes.map((it) => it.transform(mapValue: mapValue, mapGroup: mapGroup, parentNode: parentNode)).toList();

  CompositeNode<K, T> pruneByLabel(String label) {
    return pruneTrunk(
      (node) {
        return node.map(
          value: (value) {
            final a = defaultStringForOption(value.value).toLowerCase();
            final b = label.toLowerCase();
            return a.contains(b);
          },
          group: (group) {
            return true;
          },
        );
      },
    );
  }
}

enum PruneByLabelBehavior { contains, startsWith }

extension NullableCompositeNodeX<K, T> on CompositeNode<K, T>? {
  CompositeGroup<K, T> asGroup() {
    final node = this;

    if (node == null) {
      return CompositeGroup.empty();
    }

    return node.map(
      group: (group) => group,
      value: (value) => CompositeGroup.root(nodes: {value}),
    );
  }

  void traverse({
    required int depth,
    required void Function(CompositeNode<K, T> item, int depth) visit,
    bool skipRoot = false,
  }) {
    if (this == null) {
      return;
    }

    if (skipRoot && depth == 0 && this is CompositeGroup<K, T>) {
      final group = this as CompositeGroup<K, T>?;
      for (final childNode in group?.nodes.toList() ?? <CompositeNode<K, T>>[]) {
        childNode.traverse(depth: depth, visit: visit);
      }
    } else {
      traverseTree(depth: depth, visit: visit);
    }
  }

  void traverseTree({
    required int depth,
    required void Function(CompositeNode<K, T> item, int depth) visit,
  }) {
    final node = this;
    if (node == null) {
      return;
    }

    node.when(
      group: (label, items) {
        visit(node, depth);
        for (final node in items) {
          node.traverse(depth: depth + 1, visit: visit);
        }
      },
      value: (value) => visit(node, depth),
    );
  }

  CompositeNode<K, T>? pruneTrunk(bool Function(CompositeNode<K, T> node) predicate) {
    final node = this;
    if (node == null) {
      return null;
    }

    return node.pruneTrunk(predicate);
  }

  CompositeNode<K, T> pruneByLabel(
    String Function(T?) stringForOption,
    String label, {
    PruneByLabelBehavior behavior = PruneByLabelBehavior.contains,
  }) {
    return pruneTrunk(
          (node) {
            return node.map(
              value: (value) {
                final a = stringForOption(value.value).toLowerCase();
                final b = label.toLowerCase();

                return switch (behavior) {
                  PruneByLabelBehavior.contains => a.contains(b),
                  PruneByLabelBehavior.startsWith => a.startsWith(b),
                };
              },
              group: (group) => true,
            );
          },
        ) ??
        CompositeGroup.empty();
  }

  List<DepthCompositeNode<K, T>> get flattened {
    final result = <DepthCompositeNode<K, T>>[];

    traverse(
      depth: 0,
      skipRoot: true,
      visit: (item, depth) {
        result.add(DepthCompositeNode<K, T>(node: item, depth: depth));
      },
    );

    return result;
  }

  CompositeValue<K, T>? findByKey(K? key) {
    final node = this;
    if (node == null) {
      return null;
    }

    return node.map(
      group: (group) {
        for (final item in group.nodes) {
          final result = item.findByKey(key);
          if (result != null) {
            return result;
          }
        }
        return null;
      },
      value: (value) {
        if (value.key == key) {
          return value;
        } else {
          return null;
        }
      },
    );
  }

  CompositeValue<K, T>? findByValue(T? value) {
    final node = this;
    if (node == null) {
      return null;
    }

    return node.map(
      group: (group) {
        for (final item in group.nodes) {
          final result = item.findByValue(value);
          if (result != null) {
            return result;
          }
        }
        return null;
      },
      value: (value) {
        if (value.value == value) {
          return value;
        } else {
          return null;
        }
      },
    );
  }

  CompositeValue<K, T>? findByDisplayValue(String? displayValue, String Function(T? value) displayStringForOption) {
    final node = this;
    if (node == null) {
      return null;
    }

    return node.map(
      group: (group) {
        for (final item in group.nodes) {
          final result = item.findByDisplayValue(displayValue, displayStringForOption);
          if (result != null) {
            return result;
          }
        }
        return null;
      },
      value: (value) {
        if (displayStringForOption(value.value) == displayValue) {
          return value;
        } else {
          return null;
        }
      },
    );
  }
}
