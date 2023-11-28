extension CoreListExtensions<E> on List<E> {
  /// Switch the item at [fromIndex] with the item at [toIndex].
  void swap(int fromIndex, int toIndex) {
    final element = this[fromIndex];
    this[fromIndex] = this[toIndex];
    this[toIndex] = element;
  }

  /// Apply the [map] function to the item at [index]. The type should be the same.
  void mapAt({
    required int index,
    required E Function(E item) map,
  }) {
    final originalElement = this[index];
    this[index] = map(originalElement);
  }

  /// Put [item] between elements of a non-empty list. Empty list is returned as is.
  List<E> putBetween(E item) {
    final result = <E>[];
    forEach((element) {
      result.add(element);
      result.add(item);
    });

    if (result.isNotEmpty) {
      result.removeLast();
    }

    return result;
  }
}
