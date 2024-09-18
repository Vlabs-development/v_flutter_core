// ignore_for_file: sort_constructors_first

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';
import 'package:v_flutter_core/src/utils/disposable/disposable_list.dart';
import 'package:v_flutter_core/src/utils/disposable/disposable_map_group.dart';
import 'package:v_flutter_core/v_flutter_core.dart' hide CoreMapExtensions;

const getDependencyStreamsRequiresGetItem = 'Must define fetchItem for getItemDependencyStreams to work.';
const getItemTriggerStreamRequiresGetItem = 'Must define fetchItem for getItemTriggerStream to work.';
const deferItemIdUpdateRequiresGetItemTriggerStream =
    'In order to make use of deferItemIdUpdate LiveList has to operate with getItemTriggerStream';
const listDependenciesRequiresFetchItem = 'Must define fetchItem for listDependency to work.';
const unusedFetchItem = 'fetchItem is unused if neither getItemTriggerStream nor getItemDependencyStreams are defined.';

typedef _ResolvableItemDependencyRecord<T> = (String? Function(T), TriggerStream Function(String));
typedef _KeyResolvedItemDependencyMap = Map<String, TriggerStream Function(String)>;

typedef ItemStream<T> = Stream<T>;
typedef TriggerStream = Stream<void>;

class ListDependency<T> {
  ListDependency({
    required this.triggerStream,
    required this.itemPredicate,
  });

  final TriggerStream triggerStream;
  final bool Function(T) itemPredicate;
}

bool _alwaysTrue(dynamic value) => true;
FutureOr<List<_ResolvableItemDependencyRecord<dynamic>>> _empty(dynamic value) async => [];

const _itemUpdatedStreamKey = 'itemUpdatedStreamKey';
const _itemDependencyStreamKey = 'itemDependencyStreamKey';

class LiveList<ID, T> {
  final Stream<Iterable<T>> itemListStream;
  final ItemStream<T> itemCreatedStream;
  final ItemStream<T> Function(ID id)? getItemUpdatedStream;
  final TriggerStream Function(ID id)? getItemTriggerStream;
  final TriggerStream triggerPredicateReevaluation;
  final FutureOr<List<_ResolvableItemDependencyRecord<T>>> Function(T item) getItemDependencyStreams;

  final ReaderTaskEither<ID, Object?, T>? fetchItem;
  final ID Function(T item) resolveId;
  final bool Function(T item) includePredicate;
  final bool Function(T item) listenPredicate;

  final Map<ID, HandshakeCompleter<T>> _deferredItemTriggers = {};
  final Map<ID, bool> _needsEmittingDeferredItem = {};
  final Map<ID, int> _deferredItemTriggerCounts = {};
  final Map<ID, bool> _hasReturnedIdAfterDeferred = {};

  final List<ListDependency<T>> listDependencies;

  LiveList({
    required this.resolveId,
    required this.itemListStream,
    this.getItemUpdatedStream,
    this.getItemTriggerStream,
    this.triggerPredicateReevaluation = const Stream.empty(),
    this.itemCreatedStream = const Stream.empty(),
    this.includePredicate = _alwaysTrue,
    this.listenPredicate = _alwaysTrue,
    this.listDependencies = const [],
    FutureOr<List<_ResolvableItemDependencyRecord<T>>> Function(T item)? getItemDependencyStreams,
    Future<T> Function(ID id)? fetchItem,
  })  : getItemDependencyStreams = getItemDependencyStreams ?? _empty,
        fetchItem =
            fetchItem != null ? ReaderTaskEither<ID, Object?, T>.tryCatch((id) => fetchItem(id), (o, s) => o) : null {
    if (getItemDependencyStreams != null && fetchItem == null) {
      throw ArgumentError(getDependencyStreamsRequiresGetItem);
    }
    if (getItemTriggerStream != null && fetchItem == null) {
      throw ArgumentError(getItemTriggerStreamRequiresGetItem);
    }
    if (listDependencies.isNotEmpty && fetchItem == null) {
      throw ArgumentError(listDependenciesRequiresFetchItem);
    }
    final liveUpdates = _subject.asMaterializedChangeStream(resolveId);

    _disposableList.addStreamSubscription(itemListStream.listen((items) => _replaceItems(items)));
    _disposableList.addStreamSubscription(itemCreatedStream.listen((item) => upsertItem(item)));
    _disposableList.addStreamSubscription(triggerPredicateReevaluation.listen((_) => _subject.add(items)));
    _disposableList.addStreamSubscription(_actualizeItemSubscriptions(liveUpdates));
    _disposableList.addStreamSubscription(_actualizeItemDependencySubscriptions(liveUpdates));
    _disposableList.addAllStreamSubscription(listDependencies.map((d) => _listDependencySubscription(d)));
  }

  final _subject = BehaviorSubject<Iterable<T>>();
  final _disposableList = DisposableList();
  final _disposableMapGroup = DisposableMapGroup<ID, String>();
  final _dependencyStreams = <ID, Map<String, Stream<String>>>{};

  void dispose() {
    _disposableList.dispose();
    _disposableMapGroup.dispose();
    _subject.close();
  }

  Stream<List<T>> get stream => _subject.stream.map((event) => event.where(includePredicate).toList());
  Iterable<T> get items => _subject.value;
  T? getItem(ID id) => items.firstWhereOrNull((item) => resolveId(item) == id);
  Stream<T> getItemStream(ID id) => stream
      .map((items) => items.firstWhereOrNull((item) => resolveId(item) == id)) //
      .whereType<T>();
  T requireItem(ID id) => items.firstWhere((item) => resolveId(item) == id);

  void upsertItem(T externalItem) => _mergeItem(externalItem);
  T? removeItem(ID id) => _removeItemById(id);

  Future<Either<Object?, T>?> refreshItem(ID id) async {
    final _fetchItem = fetchItem;

    if (_fetchItem == null) {
      return const Left('fetchItem is not defined');
    }

    final item = await _fetchItem.run(id);
    item.match(
      (l) => null,
      (updatedItem) => upsertItem(updatedItem),
    );
    return item;
  }

  /// The returned [HandshakeCompleter] gives a handle to control the case when an async action that returns a [T] is in progress
  /// (which should be represented by the [HandshakeCompleter] future) and meanwhile there is either an itemTriggerStream or a
  /// itemDependencyStream event occuring. For such cases the event is not directly mapped to a [fetchItem] call
  ///
  HandshakeCompleter<T> deferItemTrigger(ID id) {
    if (getItemTriggerStream == null) {
      throw ArgumentError(deferItemIdUpdateRequiresGetItemTriggerStream);
    }

    final completer = HandshakeCompleter<T>();
    _deferredItemTriggers[id] = completer;
    completer.future.then((value) {
      return _deferredItemTriggers.remove(id);
    }).catchError((_) {
      return _deferredItemTriggers.remove(id);
    });

    return completer;
  }

  MapEntry<ID, Stream<T>> _getItemUpdatedStreamMapEntry(T item) => MapEntry(
        resolveId(item),
        Rx.merge([
          _getItemUpdatedStream(item),
          _getDeferredItemTriggerdStream(item),
        ]),
      );
  Stream<T> _getItemUpdatedStream(T item) => getItemUpdatedStream?.call(resolveId(item)) ?? Stream<T>.empty();

  Stream<T> _getDeferredItemTriggerdStream(T item) {
    final _fetchItem = fetchItem;
    final _getItemTriggerStream = getItemTriggerStream;

    if (_getItemTriggerStream == null) {
      return const Stream.empty();
    }

    if (_fetchItem == null) {
      throw ArgumentError(getItemTriggerStreamRequiresGetItem);
    }

    final id = resolveId(item);
    final itemTriggerStream = _getItemTriggerStream(id);
    final deferredItemTriggerStream = _awaitItemWhenDeferred(itemTriggerStream.map((_) => id));
    return deferredItemTriggerStream.asyncMap((id) => _fetchItem.maybeRight(id)).whereType<T>();
  }

  Stream<ID> _awaitItemWhenDeferred(Stream<ID> stream) {
    return stream.flatMap((id) {
      return Stream.fromFuture(
        Future(
          () async {
            final completer = _deferredItemTriggers[id];
            final deferredItemFuture = completer?.future;
            if (completer == null || deferredItemFuture == null) {
              return id;
            }

            completer.setRequiresHandshake();

            try {
              _needsEmittingDeferredItem.putIfAbsent(id, () => true);
              _deferredItemTriggerCounts[id] = (_deferredItemTriggerCounts[id] ?? 0) + 1;
              final deferredItem = await deferredItemFuture;
              if (_needsEmittingDeferredItem[id] ?? false) {
                upsertItem(deferredItem);
                _needsEmittingDeferredItem.remove(id);
              }
              if (_deferredItemTriggerCounts[id]! > 1 && !(_hasReturnedIdAfterDeferred[id] ?? false)) {
                _deferredItemTriggerCounts[id] = 0; // Reset the counter after handling
                _hasReturnedIdAfterDeferred[id] = true; // Mark that the id has been returned
                return id;
              }
              return null;
            } catch (e) {
              if (_needsEmittingDeferredItem[id] ?? false) {
                _needsEmittingDeferredItem.remove(id);
                return id;
              }
              return null;
            } finally {
              if (!completer.isHandshaked) {
                completer.handshake();
              }
              _hasReturnedIdAfterDeferred[id] = false; // Reset the flag for the next defer
            }
          },
        ),
      );
    }).whereType<ID>();
  }

  StreamSubscription<MaterializedIterableChanges<T>> _actualizeItemSubscriptions(
    Stream<MaterializedIterableChanges<T>> stream,
  ) =>
      stream.listen((event) {
        final notAnymoreRelevantItems = event.restItems.where((item) => !listenPredicate(item));
        final irrelevantItems = [...event.removedItems, ...notAnymoreRelevantItems];
        irrelevantItems.map(resolveId).forEach(_disposableMapGroup.removeByKey);

        final relevantItems = [...event.newItems, ...event.restItems];
        relevantItems
            .where(listenPredicate)
            .where((item) => _disposableMapGroup.missesItemUpdatedStreamSubscription(resolveId(item)))
            .map(_getItemUpdatedStreamMapEntry)
            .asMap
            .forEach(
              (key, value) => _disposableMapGroup.addStreamSubscription(
                key,
                _itemUpdatedStreamKey,
                value.listen((updatedItem) => upsertItem(updatedItem)),
              ),
            );
      });

  StreamSubscription<MaterializedIterableChanges<T>> _actualizeItemDependencySubscriptions(
    Stream<MaterializedIterableChanges<T>> stream,
  ) =>
      stream.listen((event) async {
        final notAnymoreRelevantItems = event.restItems.where((item) => !listenPredicate(item));
        final irrelevantItems = [...event.removedItems, ...notAnymoreRelevantItems];
        irrelevantItems.map(resolveId).forEach(_disposableMapGroup.removeByKey);

        final relevantItems = [...event.newItems, ...event.restItems].where(listenPredicate);

        await Future.wait(
          relevantItems.map((item) async {
            final keyResolvedDependencyMap = _keyResolveDependencyList(item, await this.getItemDependencyStreams(item));
            _reflectDependencyChanges(resolveId(item), keyResolvedDependencyMap);
          }),
        );
      });

  _KeyResolvedItemDependencyMap _keyResolveDependencyList(
    T item,
    List<_ResolvableItemDependencyRecord<T>> dependencyList,
  ) {
    final _KeyResolvedItemDependencyMap result = {};

    for (final (resolveKey, getDependencyStream) in dependencyList) {
      final maybeKey = resolveKey(item);

      if (maybeKey != null) {
        result[maybeKey] = getDependencyStream;
      }
    }

    return result;
  }

  void _reflectDependencyChanges(ID itemId, _KeyResolvedItemDependencyMap keyResolvedDependencyMap) {
    final existingDependencyKeys = _dependencyStreams.getSubKeys(itemId);
    final noLongerDependingOn = existingDependencyKeys //
        .where((key) => !keyResolvedDependencyMap.containsKey(key))
        .toList();
    for (final dependencyKey in noLongerDependingOn) {
      _dependencyStreams.removeByKeys(itemId, dependencyKey);
    }

    final otherDependencyKeys = _dependencyStreams
        .filterWithKey((key, _) => key != itemId)
        .values
        .map((map) => map.keys)
        .expand((keyList) => keyList);
    final keysThatOtherItemsAlsoDependOn = keyResolvedDependencyMap //
        .filterWithKey((key, value) => otherDependencyKeys.contains(key))
        .keys;
    if (keysThatOtherItemsAlsoDependOn.isNotEmpty) {
      throw ArgumentError(
        'Some other item is already depending on $keysThatOtherItemsAlsoDependOn. In this case consider using [listDependency] instead. Which is only listening for a mutual stream once.',
      );
    }

    final newlyDependingOn = keyResolvedDependencyMap
        .filterWithKey((key, _) => !_dependencyStreams.containsKeys(itemId, key))
        .map((key, getDependencyStream) => MapEntry(key, getDependencyStream(key)))
        .mapValue((stream) => stream.map((event) => itemId))
        .mapValue((stream) => _awaitItemWhenDeferred(stream))
        .map((key, stream) => MapEntry(key, stream.map((event) => key)));
    _dependencyStreams.addAllAt(itemId, newlyDependingOn);

    if (noLongerDependingOn.isNotEmpty || newlyDependingOn.isNotEmpty) {
      final streams = _dependencyStreams[itemId] ?? {};

      for (final key in noLongerDependingOn) {
        _disposableMapGroup.removeByKeys(itemId, '${_itemDependencyStreamKey}_$key');
      }

      for (final entry in newlyDependingOn.entries) {
        final key = entry.key;
        final stream = entry.value;

        _disposableMapGroup.addOrReplaceStreamSubscription(
          itemId,
          '${_itemDependencyStreamKey}_$key',
          stream
              .exhaustMap((_) => Rx.fromCallable<T?>(() => fetchItem?.maybeRight(itemId)))
              .whereType<T>()
              .listen((item) => upsertItem(item)),
        );
      }

      if (streams.isEmpty) {
        _disposableMapGroup.removeByKey(itemId);
      }
    }
  }

  StreamSubscription<void> _listDependencySubscription(ListDependency<T> dependency) {
    return dependency.triggerStream.listen((_) async {
      final _fetchItem = fetchItem;
      if (_fetchItem == null) {
        throw ArgumentError(getItemTriggerStreamRequiresGetItem);
      }

      final needsUpdate = items.where((item) => dependency.itemPredicate(item));
      for (final item in needsUpdate) {
        final updatedItem = await _fetchItem.run(resolveId(item));
        updatedItem.match(
          (l) {},
          (updatedItem) => upsertItem(updatedItem),
        );
      }
    });
  }

  void _mergeItem(T item) => _mergeItems([item]);

  void _mergeItems(Iterable<T> items) => _update((currentItems) => currentItems.merge(items, equateBy: resolveId));

  void _replaceItems(Iterable<T> items) => _update((currentItems) => items);

  T? _removeItemById(ID id) {
    T? removedItem;
    _update((currentItems) {
      final newList = [...currentItems];
      removedItem = newList.firstWhereOrNull((it) => resolveId(it) == id);
      newList.removeWhere((it) => resolveId(it) == id);
      return newList;
    });
    return removedItem;
  }

  void _update(Iterable<T> Function(Iterable<T>) callback) {
    final currentItems = _subject.valueOrNull;
    if (currentItems == null) {
      _subject.add(callback([]));
    } else {
      _subject.add(callback(currentItems));
    }
  }
}

class IterableChange<T> {
  IterableChange({
    required this.previous,
    required this.next,
  });

  final Iterable<T>? previous;
  final Iterable<T> next;
}

class MaterializedIterableChanges<T> {
  MaterializedIterableChanges({
    required this.restItems,
    required this.newItems,
    required this.removedItems,
  });

  final Iterable<T> restItems;
  final Iterable<T> newItems;
  final Iterable<T> removedItems;
}

extension _BehaviorSubjectOfIterableExtension<T> on BehaviorSubject<Iterable<T>> {
  Stream<IterableChange<T>> get asIterableChangeStream =>
      stream.map((event) => event as Iterable<T>?).startWith(null).scan<IterableChange<T>?>(
        (acc, current, index) {
          if (current == null) {
            return null;
          }
          if (acc == null) {
            return IterableChange(previous: null, next: current);
          } else {
            return IterableChange(previous: acc.next, next: current);
          }
        },
        null,
      ).whereType<IterableChange<T>>();

  Stream<MaterializedIterableChanges<T>> asMaterializedChangeStream<ID>(ID Function(T item) resolveId) {
    return asIterableChangeStream.map((event) {
      final previous = event.previous;
      final _previous = previous ?? [];
      final previousIds = _previous.map(resolveId).toList();
      final next = event.next.toList();
      final nextIds = next.map(resolveId).toList();

      final newIds = nextIds.where((id) => !previousIds.contains(id)).toList();
      final removedIds = previousIds.where((id) => !nextIds.contains(id)).toList();

      final newItems = next.where((item) => newIds.contains(resolveId(item)));
      final removedItems = _previous.where((item) => removedIds.contains(resolveId(item)));
      final restItems = next.where((item) {
        final id = resolveId(item);
        return !newIds.contains(id) && !removedIds.contains(id);
      });

      return MaterializedIterableChanges(newItems: newItems, restItems: restItems, removedItems: removedItems);
    });
  }
}

typedef _NestedMap<Key, InnerKey, Value> = Map<Key, Map<InnerKey, Value>>;

extension _NestedMapX<Key, InnerKey, Value> on _NestedMap<Key, InnerKey, Value> {
  Iterable<InnerKey> getSubKeys(Key key) => this[key]?.keys ?? [];
  void removeByKeys(Key key, InnerKey innerKey) {
    if (containsKey(key)) {
      this[key]?.remove(innerKey);
    }
  }

  bool containsKeys(Key key, InnerKey innerKey) => containsKey(key) && this[key]!.containsKey(innerKey);
  void addAllAt(Key key, Map<InnerKey, Value> map) {
    this[key] = {...this[key] ?? {}, ...map};
  }
}

extension DisposableMapGroupExtensions<ID> on DisposableMapGroup<ID, String> {
  bool containsItemUpdatedStreamSubscription(ID id) => containsKeys(id, _itemUpdatedStreamKey);
  bool missesItemUpdatedStreamSubscription(ID id) => !containsItemUpdatedStreamSubscription(id);
}

extension _IterableX<K, T> on Iterable<MapEntry<K, T>> {
  Map<K, T> get asMap => Map.fromEntries(this);
}

extension _ReaderTaskEitherX<E, L, R> on ReaderTaskEither<E, L, R> {
  Future<R?> maybeRight(E e) async => (await run(e)).match((l) => null, (r) => r);
}
