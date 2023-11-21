import 'package:v_flutter_core/src/utils/composite_node/composite_node.dart';

class DepthCompositeNode<K, T> {
  DepthCompositeNode({
    required this.node,
    required this.depth,
  });

  final CompositeNode<K, T> node;
  final int depth;
}

class DepthCompositeGroup<K, T> {
  DepthCompositeGroup({
    required this.group,
    required this.depth,
  });

  final CompositeGroup<K, T> group;
  final int depth;
}

class DepthCompositeValue<K, T> {
  DepthCompositeValue({
    required this.value,
    required this.depth,
  });

  final CompositeValue<K, T> value;
  final int depth;
}

extension FlattenedCompositeNodeX<K, T> on DepthCompositeNode<K, T> {
  R when<R>({
    required R Function(T value) value,
    required R Function(String label, List<CompositeNode<K, T>> items) group,
  }) =>
      node.when(value: value, group: group);

  R map<R>({
    required R Function(DepthCompositeValue<K, T> value) value,
    required R Function(DepthCompositeGroup<K, T> group) group,
  }) {
    return node.map(
      value: (v) => value(DepthCompositeValue(value: v, depth: depth)),
      group: (g) => group(DepthCompositeGroup(group: g, depth: depth)),
    );
  }
}
