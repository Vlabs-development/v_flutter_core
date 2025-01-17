// ignore_for_file: sort_constructors_first

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';
import 'package:v_flutter_core/src/utils/disposable/disposable_list.dart';
import 'package:v_flutter_core/src/utils/live_list/dependency_collection.dart';
import 'package:v_flutter_core/src/utils/live_list/trigger_executor.dart';
import 'package:v_flutter_core/v_flutter_core.dart' hide CoreMapExtensions;

const _listTriggersRequiresFetchItems = 'Must define fetchItems for listTriggers to work.';

enum ItemListStreamBehavior {
  /// Replaces all existing items with the new items from the stream
  replace,

  /// Adds new items to the existing collection
  add
}

typedef IdStream = Stream<String>;
typedef TriggerStream = Stream<void>;
typedef TriggerMap = Map<String, TriggerStream Function(String)>;

bool _alwaysTrue(dynamic value) => true;

class TriggerDefinition<T> {
  final String? Function(T) selectKey;
  final TriggerStream Function(String) getTriggerStream;
  final bool Function(T) when;

  TriggerDefinition(
    this.selectKey,
    this.getTriggerStream, {
    this.when = _alwaysTrue,
  });
}

class ListTriggerDefinition<T> {
  ListTriggerDefinition({
    required this.appliesTo,
    required this.stream,
  });

  final bool Function(T) appliesTo;
  final TriggerStream stream;
}

FutureOr<List<TriggerDefinition<T>>> _empty<T>(dynamic value) async => [];

ReaderTaskEither<ID, Object?, T> _wrapFetchItem<ID, T>(Future<T> Function(ID) fetchItem) {
  return ReaderTaskEither<ID, Object?, T>.tryCatch((id) => fetchItem(id), (o, s) => o);
}

ReaderTaskEither<Iterable<ID>, Object?, List<T>> _wrapFetchItems<ID, T>(
  Future<List<T>> Function(Iterable<ID>)? fetchItems,
) =>
    fetchItems == null
        ? ReaderTaskEither<Iterable<ID>, Object?, List<T>>.tryCatch((ids) => Future.value([]), (o, s) => o)
        : ReaderTaskEither<Iterable<ID>, Object?, List<T>>.tryCatch((ids) => fetchItems(ids), (o, s) => o);

class LiveList<ID, T> {
  final Stream<Iterable<T>> itemListStream;
  final Stream<ID> itemCreatedTriggerStream;
  final ItemListStreamBehavior itemListStreamBehavior;

  final ReaderTaskEither<ID, Object?, T> fetchItem;
  final ReaderTaskEither<Iterable<ID>, Object?, List<T>> fetchItems;
  final ID Function(T item) resolveId;

  final FutureOr<List<TriggerDefinition<T>>> Function(T item) getTriggerDefinitions;
  final List<ListTriggerDefinition<T>> listTriggers;

  final DependencyCollection<ID> _dependencyCollection = DependencyCollection<ID>();
  final TriggerExecutor<ID, T> _triggerExecutor;

  LiveList({
    required this.resolveId,
    required Future<T> Function(ID id) fetchItem,
    Future<List<T>> Function(Iterable<ID> ids)? fetchItems,
    this.itemListStream = const Stream.empty(),
    this.itemCreatedTriggerStream = const Stream.empty(),
    this.listTriggers = const [],
    this.itemListStreamBehavior = ItemListStreamBehavior.replace,
    FutureOr<List<TriggerDefinition<T>>> Function(T item)? getTriggerDefinitions,
  })  : _triggerExecutor = TriggerExecutor<ID, T>(fetchItem: _wrapFetchItem(fetchItem)),
        getTriggerDefinitions = getTriggerDefinitions ?? _empty,
        fetchItem = _wrapFetchItem(fetchItem),
        fetchItems = _wrapFetchItems(fetchItems) {
    if (listTriggers.isNotEmpty && fetchItems == null) {
      throw ArgumentError(_listTriggersRequiresFetchItems);
    }
    final liveUpdates = _subject.asMaterializedChangeStream(resolveId);

    _disposableList.addStreamSubscription(itemListStream.listen((items) => _handleItemListUpdate(items)));
    _disposableList.addStreamSubscription(_dependencyCollection.triggerStream.listen((id) => _triggerExecutor.add(id)));
    _disposableList.addStreamSubscription(_triggerExecutor.itemStream.listen((item) => upsertItem(item)));
    _disposableList.addStreamSubscription(itemCreatedTriggerStream.listen((id) => refreshItem(id)));
    _disposableList.addStreamSubscription(_actualizeTriggerSubscriptions(liveUpdates));
    _disposableList.addAllStreamSubscription(listTriggers.map((d) => _listDependencySubscription(d)));
  }

  final _subject = BehaviorSubject<Iterable<T>>(sync: true);
  final _disposableList = DisposableList();

  void dispose() {
    _disposableList.dispose();
    _subject.close();
    _triggerExecutor.dispose();
    _dependencyCollection.dispose();
  }

  Stream<List<T>> get stream => _subject.stream.map((iterable) => iterable.toList());
  Iterable<T> get items => _subject.valueOrNull ?? [];

  T? getItem(ID id) => items.firstWhereOrNull((item) => resolveId(item) == id);
  Stream<T> getItemStream(ID id) => stream
      .map((items) => items.firstWhereOrNull((item) => resolveId(item) == id)) //
      .whereType<T>();
  T requireItem(ID id) => items.firstWhere((item) => resolveId(item) == id);

  void upsertItem(T externalItem) => _mergeItem(externalItem);
  T? removeItem(ID id) => _removeItemById(id);
  void clear() => _subject.add([]);

  Future<Either<Object?, T>?> refreshItem(ID id) async {
    final _fetchItem = fetchItem;

    final item = await _fetchItem.run(id);
    item.match(
      (l) => null,
      (updatedItem) => upsertItem(updatedItem),
    );
    return item;
  }

  /// The returned [Completer] gives a handle to control the case when an async action that returns a [T] is in progress
  /// (which should be represented by the [Completer] future) and meanwhile there is a
  /// itemDependencyStream event occuring. For such cases the event is not directly mapped to a [fetchItem] call.
  Either<Future<T>, Completer<T>> deferItemTrigger(ID id) {
    return _triggerExecutor.deferItemTrigger(id);
  }

  Future<Completer<T>> asyncDeferItemTrigger(ID id) async {
    return _triggerExecutor.asyncDeferItemTrigger(id);
  }

  StreamSubscription<MaterializedIterableChanges<T>> _actualizeTriggerSubscriptions(
    Stream<MaterializedIterableChanges<T>> stream,
  ) =>
      stream.listen((event) async {
        final irrelevantItems = [...event.removedItems];
        irrelevantItems.map(resolveId).forEach(_dependencyCollection.removeByKey);

        final items = [...event.newItems, ...event.restItems];

        await Future.wait(
          items.map((item) async {
            final triggerDefinitions = await this.getTriggerDefinitions(item);
            final triggerMap = _resolveTriggerDefinitionList(
              item,
              triggerDefinitions.where((def) => def.when(item)).toList(),
            );
            _dependencyCollection.reflectDependencyChanges(resolveId(item), triggerMap);
          }),
        );
      });

  TriggerMap _resolveTriggerDefinitionList(
    T item,
    List<TriggerDefinition<T>> triggerDefinitionList,
  ) {
    final Map<String, TriggerStream Function(String)> result = {};

    for (final dependency in triggerDefinitionList) {
      final maybeKey = dependency.selectKey(item);

      if (maybeKey != null) {
        if (result.containsKey(maybeKey)) {
          debugPrint('⚠️⚠️ ${resolveId(item)} has more than one dependency stream at key: $maybeKey');
        }

        result[maybeKey] = dependency.getTriggerStream;
      }
    }

    return result;
  }

  StreamSubscription<void> _listDependencySubscription(ListTriggerDefinition<T> dependency) {
    return dependency.stream.listen((_) async {
      final _fetchItems = fetchItems;

      final needsUpdate = items.where((item) => dependency.appliesTo(item));
      final ids = needsUpdate.map(resolveId).toList();
      final updatedItems = await _fetchItems.run(ids);
      updatedItems.match(
        (l) {},
        (updatedItems) => _mergeItems(updatedItems),
      );
    });
  }

  void _mergeItem(T item) => _mergeItems([item]);

  void _mergeItems(Iterable<T> items) => _update((currentItems) => currentItems.merge(items, equateBy: resolveId));

  void _replaceItems(Iterable<T> items) => _update((currentItems) => items);

  void _handleItemListUpdate(Iterable<T> items) {
    switch (itemListStreamBehavior) {
      case ItemListStreamBehavior.replace:
        _replaceItems(items);
      case ItemListStreamBehavior.add:
        _mergeItems(items);
    }
  }

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
