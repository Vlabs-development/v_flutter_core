// ignore_for_file: sort_constructors_first

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';
import 'package:v_flutter_core/src/utils/disposable_collection.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

bool _alwaysTrue(dynamic value) => true;
Map<String? Function(dynamic), Stream<void> Function(String)> _empty(dynamic value) => {};

Future<Option<T>> Function(ID) wrapMaybeFuture<T, ID>(FutureOr<T> Function(ID)? maybeFuture) {
  return (ID id) async => Option.fromNullable(await maybeFuture?.call(id));
}

class LiveList<ID, T> {
  final bool Function(T item) includePredicate;
  final bool Function(T item) listenPredicate;
  final ID Function(T item) resolveId;
  final Stream<List<T>> itemListStream;
  final Stream<T> Function(ID id) getItemUpdatedStream;
  final Stream<T> itemCreatedStream;

  final Map<String? Function(T), Stream<void> Function(String)> Function(T item) getDependencyStreams;
  final Future<Option<T>> Function(ID) getItem; // TOTO assert

  final _subject = BehaviorSubject<List<T>>();
  Stream<List<T>> get stream => _subject.stream.map((event) => event.where(includePredicate).toList());

  void dispose() {
    _disposableMap.dispose();
    _disposableList.dispose();
    _disposableMapGroup.dispose();
  }

  final _disposableMap = DisposableMap<ID>();
  final _disposableList = DisposableList();
  final _disposableMapGroup = DisposableMapGroup<ID, String>();

  LiveList({
    required this.itemListStream,
    required this.getItemUpdatedStream,
    required this.itemCreatedStream,
    required this.resolveId,
    this.includePredicate = _alwaysTrue,
    this.listenPredicate = _alwaysTrue,
    Map<String? Function(T), Stream<void> Function(String)> Function(T item)? getDependencyStreams,
    FutureOr<T> Function(ID)? getItem,
  })  : getDependencyStreams = getDependencyStreams ?? _empty,
        getItem = wrapMaybeFuture(getItem) {
    if (getDependencyStreams != null && getItem == null) {
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
            (key, value) {
              return MapEntry(key, value.asBroadcastStream());
            },
          );

          _listenForItemChanges(itemsStreams);
          _listenForDependencyChanges(
            itemsStreams.map(
              (key, value) => MapEntry(
                key,
                value.shareValueSeeded([...newItems, ...restItems].singleWhere((item) => resolveId(item) == key)),
              ),
            ),
          );

          removedItems.map((it) => resolveId(it)).forEach((key) {
            _disposableMap.removeByKey(key);
            _disposableMapGroup.removeByKey(key);
          });
        },
      ),
    );
  }

  void addItem(T externalItem) => _mergeItem(externalItem);
  void removeItem(ID id) => _removeItemById(id);

  Map<ID, Stream<T>> _getIdToStreamMap(Iterable<T> items) {
    return Map.fromEntries(items.map((item) => MapEntry(resolveId(item), getItemUpdatedStream(resolveId(item)))));
  }

  StreamSubscription _onItemsUpdate({
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

  void _listenForDependencyChanges(Map<ID, Stream<T>> itemStreamMap) {
    for (final keyedItemStream in itemStreamMap.entries) {
      if (_disposableMapGroup.containsKeys(keyedItemStream.key, 'mainTrigger')) {
        return;
      }

      final map = keyedItemStream.value
          .map((item) => (item, getDependencyStreams(item))) //
          .map(
            (event) => event.$2.map<String?, Stream<void>?>((key, value) {
              final nullableKey = key(event.$1);
              final stream = nullableKey == null ? const Stream.empty() : value(nullableKey);
              return MapEntry(key(event.$1), stream);
            }).entries,
          )
          .map((event) => Map.fromEntries(event)..removeWhere((key, value) => key == null || value == null))
          .map((event) => event.cast<String, Stream<void>>());

      final triggeringSubscription = map.listen((streamMap) {
        final subKeys = [..._disposableMapGroup.getSubKeys(keyedItemStream.key)]..remove('mainTrigger'); // BETTER
        final noLongerInterestedIn = subKeys.where((key) => !streamMap.containsKey(key)).toList();
        for (final key in noLongerInterestedIn) {
          _disposableMapGroup.removeByKeys(keyedItemStream.key, key);
        }

        final nonYetListenedToStreams = Map.fromEntries(
          streamMap.entries.where((entry) => !_disposableMapGroup.containsKeys(keyedItemStream.key, entry.key)),
        );
        final getItemStream = nonYetListenedToStreams.mapValue(
          (value) => value
              .asyncMap((event) => getItem(keyedItemStream.key))
              .map((itemOption) => itemOption.toNullable())
              .whereType<T>(),
        );
        getItemStream.forEach(
          (key, value) {
            final sub = value.listen((event) => addItem(event));
            _disposableMapGroup.addStreamSubscription(keyedItemStream.key, key, sub);
          },
        );
      });
      _disposableMapGroup.addStreamSubscription(keyedItemStream.key, 'mainTrigger', triggeringSubscription);
    }
  }

  void _mergeItem(T item) => _mergeItems([item]);

  void _mergeItems(List<T> items) => update((currentList) => currentList.merge(items, equateBy: resolveId));

  void _replaceItems(List<T> items) => update((currentList) => items);

  void _removeItemById(ID id) => update((currentList) => [...currentList]..removeWhere((it) => resolveId(it) == id));

  void update(List<T> Function(List<T>) callback) {
    _subject.add(
      Option.fromNullable(_subject.valueOrNull).match(
        () => callback([]),
        (currentList) => callback(currentList),
      ),
    );
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
