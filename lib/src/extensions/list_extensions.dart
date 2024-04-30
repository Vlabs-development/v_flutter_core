import 'package:collection/collection.dart';

extension CoreIterableExtensions<T> on Iterable<T> {
  /// Put [item] between elements of a non-empty iterable. Empty iterable is returned as is.
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

  Iterable<T> unique() => Set<T>.from(this);

  /// Includes elements from both [this] and [other] but when an item is found in both lists
  /// then the on from [other] is taken only. Items in both list should be unique because of naive merging.
  List<T> merge<R>(Iterable<T> other, {required R Function(T) equateBy}) {
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

  /// Sorts the items by the selected `DateTime?`. null values are put to the end of the list.
  List<T> sortedByDate(DateTime? Function(T) getDate, {bool ascending = true}) => sortedBy(
        (item) => _NullableDateTimeComparable(getDate(item), ascending: ascending),
      );
}

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
}

class _NullableDateTimeComparable implements Comparable<_NullableDateTimeComparable> {
  _NullableDateTimeComparable(
    this.date, {
    this.ascending = true,
  });

  final DateTime? date;
  final bool ascending;

  @override
  int compareTo(_NullableDateTimeComparable other) {
    if (date == null && other.date != null) return 1;
    if (date != null && other.date == null) return -1;
    if (date == null && other.date == null) return 0;

    if (ascending) {
      return date!.compareTo(other.date!);
    } else {
      return other.date!.compareTo(date!);
    }
  }
}
