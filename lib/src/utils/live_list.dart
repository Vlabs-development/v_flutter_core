import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:v_flutter_core/src/utils/disposable/disposable_list.dart';
import 'package:v_flutter_core/src/utils/disposable/disposable_map.dart';
import 'package:v_flutter_core/src/utils/disposable/disposable_map_group.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

typedef _DependencyRecordList<T> = List<(String? Function(T), Stream<void> Function(String))>;

bool _alwaysTrue(dynamic value) => true;
List<(String? Function(dynamic), Stream<void> Function(String))> _empty(dynamic value) => [];

const _dependencyTriggerKey = 'mainTrigger';

class LiveList<ID, T> {
  LiveList({
    required this.resolveId,
    required this.itemListStream,
    required this.getItemUpdatedStream,
    this.itemCreatedStream = const Stream.empty(),
    this.includePredicate = _alwaysTrue,
    this.listenPredicate = _alwaysTrue,
    _DependencyRecordList<T> Function(T item)? getDependencyStreams,
    this.getItem,
  }) : getDependencyStreams = getDependencyStreams ?? _empty {
    if (getDependencyStreams != null && getItem == null) {
      throw ArgumentError('Must define getItem for getDependencyStreams to work.');
    }

    assert(
      getItem == null || (getItem != null && getDependencyStreams != null),
      'getItem is unused if getDependencyStreams is not defined.',
    );

    if (getDependencyStreams == null && getItem != null) {
      throw ArgumentError('Must define getItem for getDependencyStreams to work.');
    }
    _disposableList.addStreamSubscription(itemListStream.listen((items) => _replaceItems(items)));
    _disposableList.addStreamSubscription(itemCreatedStream.listen((item) => _mergeItem(item)));
    _disposableList.addStreamSubscription(
      _onItemsUpdate(
        resolveId: resolveId,
        handle: (newItems, restItems, removedItems) {
          final itemStreamMap = _getIdToStreamMap(newItems.where(listenPredicate));
          final newlyListenableItemStreamMap = _getIdToStreamMap(
            restItems.where(listenPredicate).where((item) => !_disposableMap.containsKey(resolveId(item))),
          );
          final itemsStreams = {...itemStreamMap, ...newlyListenableItemStreamMap}.map(
            (key, value) => MapEntry(key, value.asBroadcastStream()),
          );

          _listenForItemChanges(itemsStreams);
          _maybeListenForDependencyChanges(
            itemsStreams.map(
              (key, value) => MapEntry(
                key,
                value.shareValueSeeded([...newItems, ...restItems].singleWhere((item) => resolveId(item) == key)),
              ),
            ),
          );

          removedItems.map((item) => resolveId(item)).forEach((key) {
            _disposableMap.removeByKey(key);
            _disposableMapGroup.removeByKey(key);
          });
        },
      ),
    );
  }
  final ID Function(T item) resolveId;
  final Stream<List<T>> itemListStream;
  final Stream<T> Function(ID id) getItemUpdatedStream;
  final Stream<T> itemCreatedStream;
  final bool Function(T item) includePredicate;
  final bool Function(T item) listenPredicate;

  final _DependencyRecordList<T> Function(T item) getDependencyStreams;
  final FutureOr<T> Function(ID id)? getItem;

  final _subject = BehaviorSubject<List<T>>();
  Stream<List<T>> get stream => _subject.stream.map((event) => event.where(includePredicate).toList());
  List<T> get items => _subject.value;

  void dispose() {
    _disposableMap.dispose();
    _disposableList.dispose();
    _disposableMapGroup.dispose();
  }

  final _disposableMap = DisposableMap<ID>();
  final _disposableList = DisposableList();
  final _disposableMapGroup = DisposableMapGroup<ID, String>();

  void addItem(T externalItem) => _mergeItem(externalItem);
  void removeItem(ID id) => _removeItemById(id);

  Map<ID, Stream<T>> _getIdToStreamMap(Iterable<T> items) {
    return Map.fromEntries(items.map((item) => MapEntry(resolveId(item), getItemUpdatedStream(resolveId(item)))));
  }

  StreamSubscription<List<T>> _onItemsUpdate({
    required ID Function(T item) resolveId,
    required void Function(Iterable<T> newItems, Iterable<T> restItems, Iterable<T> removedItems) handle,
  }) {
    return _subject._listenSelf((previous, next) {
      final _previous = previous ?? [];
      final previousIds = _previous.map(resolveId);
      final nextIds = next.map(resolveId);

      final newIds = nextIds.where((id) => !previousIds.contains(id));
      final removedIds = previousIds.where((id) => !nextIds.contains(id));

      final newItems = next.where((item) => newIds.contains(resolveId(item)));
      final removedItems = _previous.where((item) => removedIds.contains(resolveId(item)));
      final restItems =
          next.where((item) => !newIds.contains(resolveId(item)) && !removedIds.contains(resolveId(item)));

      handle(newItems, restItems, removedItems);
    });
  }

  void _listenForItemChanges(Map<ID, Stream<T>> itemStreamMap) {
    for (final keyedItemStream in itemStreamMap.entries) {
      final subscription = keyedItemStream.value.listen((updatedItem) {
        _mergeItem(updatedItem);
        if (!listenPredicate(updatedItem)) {
          _disposableMap.removeByKey(keyedItemStream.key);
          _disposableMapGroup.removeByKey(keyedItemStream.key);
        }
      });
      _disposableMap.addStreamSubscription(keyedItemStream.key, subscription);
    }
  }

  void _maybeListenForDependencyChanges(Map<ID, Stream<T>> itemStreamMap) {
    for (final entry in itemStreamMap.entries) {
      final itemKey = entry.key;
      final itemUpdatedStream = entry.value;

      if (!_disposableMapGroup.containsKeys(itemKey, _dependencyTriggerKey)) {
        _listenForDependencyChanges(itemKey, itemUpdatedStream);
      }
    }
  }

  void _listenForDependencyChanges(ID itemKey, Stream<T> itemUpdatedStream) {
    final Stream<Map<String, Stream<void> Function(String)>> dependencyStream = itemUpdatedStream
        .map((it) => (it, getDependencyStreams(it)))
        .map((it) => it.$2.map((e) => (e.$1(it.$1), e.$2)).whereType<(String, Stream<void> Function(String))>())
        .map((it) => Map.fromEntries(it.map((e) => MapEntry(e.$1, e.$2))));

    final dependencySub = dependencyStream.listen((dependencyMap) {
      final existingDependencyKeys = [..._disposableMapGroup.getSubKeys(itemKey)]..remove(_dependencyTriggerKey);
      final noLongerDependingOn = existingDependencyKeys.where((key) => !dependencyMap.containsKey(key)).toList();
      for (final dependencyKey in noLongerDependingOn) {
        _disposableMapGroup.removeByKeys(itemKey, dependencyKey);
      }

      final dependencyStreamMap = dependencyMap
          .filterWithKey((key, _) => !_disposableMapGroup.containsKeys(itemKey, key))
          .map((key, getDependencyStream) => MapEntry(key, getDependencyStream(key)))
          .mapValue((stream) => stream.asyncMap((_) => Future<T?>.value(getItem?.call(itemKey))).whereType<T>())
          .mapValue((stream) => stream.whereType<T>());

      dependencyStreamMap.forEach(
        (key, stream) => _disposableMapGroup.addStreamSubscription(
          itemKey,
          key,
          stream.listen((item) => addItem(item)),
        ),
      );
    });
    _disposableMapGroup.addStreamSubscription(itemKey, _dependencyTriggerKey, dependencySub);
  }

  void _mergeItem(T item) => _mergeItems([item]);

  void _mergeItems(List<T> items) => _update((currentList) => currentList.merge(items, equateBy: resolveId));

  void _replaceItems(List<T> items) => _update((currentList) => items);

  void _removeItemById(ID id) => _update((currentList) => [...currentList]..removeWhere((it) => resolveId(it) == id));

  void _update(List<T> Function(List<T>) callback) {
    final currentList = _subject.valueOrNull;
    if (currentList == null) {
      _subject.add(callback([]));
    } else {
      _subject.add(callback(currentList));
    }
  }
}

extension _BehaviorSubjectExtension<T> on BehaviorSubject<T> {
  StreamSubscription<T> _listenSelf(void Function(T? previous, T current) callback) {
    T? _previous;
    return listen((next) {
      callback(_previous, next);
      _previous = next;
    });
  }
}
