extension CoreListExtensions<T> on List<T> {
  /// Switch the item at [fromIndex] with the item at [toIndex].
  void swap(int fromIndex, int toIndex) {
    final element = this[fromIndex];
    this[fromIndex] = this[toIndex];
    this[toIndex] = element;
  }

  /// Apply the [map] function to the item at [index]. The type should be the same.
  void mapAt({
    required int index,
    required T Function(T item) map,
  }) {
    final originalElement = this[index];
    this[index] = map(originalElement);
  }

  /// Put [item] between elements of a non-empty list. Empty list is returned as is.
  List<T> putBetween(T item) {
    final result = <T>[];
    forEach((element) {
      result.add(element);
      result.add(item);
    });

    if (result.isNotEmpty) {
      result.removeLast();
    }

    return result;
  }

  bool allUnique<E>(E Function(T item) uniqueComparePropExtractor) {
    return Set.of(map((e) => uniqueComparePropExtractor(e))).length == length;
  }

  List<T> unique() => Set<T>.from(this).toList();

  /// Includes elements from both [this] and [other] but when an item is found in both lists
  /// then the on from [other] is taken only. Items in both list should be unique because of naive merging.
  List<T> merge<R>(List<T> other, {required R Function(T) equateBy}) {
    assert(allUnique(equateBy), 'Items should be unique in [this]!');
    assert(other.allUnique(equateBy), 'Items should be unique in [other]!');

    final list = [...this];

    for (final otherItem in other) {
      final index = list.indexWhere((it) => equateBy(it) == equateBy(otherItem));
      if (index == -1) {
        list.add(otherItem);
      } else {
        list[index] = otherItem;
      }
    }
    return list;
  }

  List<T> addOrReplace<R>(T item, {required R Function(T) equateBy}) {
    assert(allUnique(equateBy), 'Items should be unique in [this]!');

    final list = [...this];

    final index = list.indexWhere((it) => equateBy(it) == equateBy(item));
    if (index == -1) {
      list.add(item);
    } else {
      list[index] = item;
    }

    return list;
  }
}
