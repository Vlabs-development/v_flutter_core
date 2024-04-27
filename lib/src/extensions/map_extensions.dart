// ignore_for_file: prefer_final_locals

// Part of fpdart's map extensions
// https://github.com/SandroMaglione/fpdart/blob/d1f5f1531ac069d6d67280991fc45801deb463da/packages/fpdart/lib/src/extension/map_extension.dart

extension CoreMapExtensions<K, V> on Map<K, V> {
  /// Return number of elements in the [Map] (`keys.length`).
  int get size => keys.length;

  /// Convert each **value** of the [Map] using
  /// the `update` function and returns a new [Map].
  Map<K, A> mapValue<A>(A Function(V value) update) =>
      {for (final MapEntry(:key, :value) in entries) key: update(value)};

  /// Convert each **value** of the [Map] using
  /// the `update` function and returns a new [Map].
  Map<K, A> mapWithIndex<A>(A Function(V value, int index) update) =>
      {for (var (index, MapEntry(:key, :value)) in entries.indexed) key: update(value, index)};

  /// Returns a new [Map] containing all the elements of this [Map]
  /// where the **value** satisfies `test`.
  Map<K, V> filter(bool Function(V value) test) => {
        for (final MapEntry(:key, :value) in entries)
          if (test(value)) key: value,
      };

  /// Returns a new [Map] containing all the elements of this [Map]
  /// where the **value** satisfies `test`.
  Map<K, V> filterWithIndex(bool Function(V value, int index) test) => {
        for (var (index, MapEntry(:key, :value)) in entries.indexed)
          if (test(value, index)) key: value,
      };

  /// Returns a new [Map] containing all the elements of this [Map]
  /// where **key/value** satisfies `test`.
  Map<K, V> filterWithKey(bool Function(K key, V value) test) => {
        for (var (MapEntry(:key, :value)) in entries)
          if (test(key, value)) key: value,
      };

  /// Returns a new [Map] containing all the elements of this [Map]
  /// where **key/value** satisfies `test`.
  Map<K, V> filterWithKeyAndIndex(
    bool Function(K key, V value, int index) test,
  ) =>
      {
        for (var (index, MapEntry(:key, :value)) in entries.indexed)
          if (test(key, value, index)) key: value,
      };
}
