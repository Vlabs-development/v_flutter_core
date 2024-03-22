// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:v_flutter_core/v_flutter_core.dart';

// mixin DisposableMapMixin<IDType> {
//   Map<IDType, VoidCallback> cleanupCallbacks = {};

//   void addDisposing(IDType key, VoidCallback cleanup) {
//     if (cleanupCallbacks.containsKey(key)) {
//       throw 'Key already exists';
//     }

//     cleanupCallbacks.putIfAbsent(key, () => cleanup);
//   }

//   void addStreamSubscription(IDType key, StreamSubscription sub) => addDisposing(key, sub.cancel);

//   void dispose() {
//     for (final fn in cleanupCallbacks.values) {
//       fn.call();
//     }
//   }
// }

// class DisposableMap<IDType> with DisposableMapMixin<IDType> {
//   DisposableMap();
// }

// extension _X<T, ID> on Ref<AsyncValue<List<T>>> {
//   FutureOr _onNewItems({
//     required void Function(List<T> newItems) handle,
//     required ID Function(T item) resolveId,
//   }) {
//     listenSelf((previous, next) {
//       final previousIds = (previous?.actualValueOrNull ?? []).map(resolveId);
//       final nextItems = next.actualValueOrNull ?? [];
//       final newIds = nextItems.map(resolveId).where((id) => !previousIds.contains(id)).toList();

//       final newItems = nextItems.where((item) => newIds.contains(resolveId(item)));
//       handle(newItems.toList());
//     });
//   }
// }

// // ignore: invalid_use_of_internal_member
// mixin HoodooLiveList<T, ID> on BuildlessAutoDisposeStreamNotifier<List<T>> {
//   bool predicate(T item);
//   bool listenPredicate(T item);
//   ID resolveId(T item);

//   @nonVirtual
//   Stream<List<T>> internalBuild({
//     required Stream<List<T>> Function() getItemList,
//     required Stream<T> Function(ID item) onItemUpdated,
//     required Stream<T> Function() onItemCreated,
//   }) async* {
//     final disposableMap = DisposableMap<String>();
//     ref.onDispose(() => disposableMap.dispose());

//     disposableMap.addStreamSubscription(
//       'itemList',
//       getItemList().listen((items) {
//         state.maybeMap(
//           data: (_) => _maybeAddOrReplaceItems(items),
//           orElse: () => state = AsyncData(items),
//         );
//       }),
//     );
//     disposableMap.addStreamSubscription(
//       'itemCreated',
//       onItemCreated()
//           .doOnData((event) => debugPrint('__ Item with id ${resolveId(event)} got created'))
//           .listen((item) => _maybeAddOrReplaceItem(item)),
//     );

//     ref._onNewItems(
//       resolveId: resolveId,
//       handle: (newItems) {
//         final itemStreamMap = Map.fromEntries(
//           newItems.where(listenPredicate).map(
//                 (item) => MapEntry(
//                   'itemUpdated-${resolveId(item)}',
//                   onItemUpdated(resolveId(item))
//                       .doOnListen(() => debugPrint('__ Listening for changes of ${resolveId(item)}'))
//                       .doOnCancel(() => debugPrint('__ Not listening anymore for changes of ${resolveId(item)}')),
//                 ),
//               ),
//         );

//         _listenForItemChanges(
//           itemStreamMap,
//           disposableMap,
//         );
//       },
//     );
//   }

//   void addItem(T externalItem) {
//     _maybeAddOrReplaceItem(externalItem);
//   }

//   void _listenForItemChanges(Map<String, Stream<T>> itemStreamMap, DisposableMap<String> disposableMap) {
//     for (final keyedItemStream in itemStreamMap.entries) {
//       StreamSubscription? subscription;
//       subscription = keyedItemStream.value.listen((updatedItem) {
//         if (predicate(updatedItem)) {
//           _maybeAddOrReplaceItem(updatedItem);
//         } else {
//           subscription?.cancel();
//           _removeItemById(resolveId(updatedItem));
//         }
//       });
//       disposableMap.addStreamSubscription(keyedItemStream.key, subscription);
//     }
//   }

//   void _maybeAddOrReplaceItem(T item) {
//     _maybeAddOrReplaceItems([item]);
//   }

//   void _maybeAddOrReplaceItems(List<T> items) {
//     update((originalApiList) => originalApiList.merge(items, equateBy: resolveId).where(predicate).toList());
//   }

//   void _removeItemById(ID id) {
//     update(
//       (originalApiList) => [...originalApiList..removeWhere((item) => resolveId(item) == id)],
//     );
//   }
// }
