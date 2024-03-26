// ignore_for_file: unreachable_from_main

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';
import 'package:v_flutter_core/src/utils/disposable_collection.dart';
import 'package:v_flutter_core/src/utils/live_list.dart';

import 'stream.dart';

const a = _Model(id: 'a', name: 'A', foreignId: '1');
const aa = _Model(id: 'a', name: 'AA', foreignId: '2');
const aaa = _Model(id: 'a', name: 'AAA', foreignId: '2');
const aaaa = _Model(id: 'a', name: 'AAAA', foreignId: '3');
const b = _Model(id: 'b', name: 'B');
const bb = _Model(id: 'b', name: 'BB');
const bbb = _Model(id: 'b', name: 'BBB');
const c = _Model(id: 'c', name: 'C');
const cc = _Model(id: 'c', name: 'CC');
const ccc = _Model(id: 'c', name: 'CCC');

bool _listenPredicate(_Model item) => true;
String _resolveId(_Model item) => item.id;
bool _includePredicate(_Model item) => true;

class ItemUpdateEvent {
  ItemUpdateEvent({
    required this.id,
    this.after = Duration.zero,
    required this.next,
  });

  final String id;
  final Duration after;
  final _Model next;
}

class ItemTriggeringEvent {
  ItemTriggeringEvent({
    this.after = Duration.zero,
  });

  final Duration after;
}

class ItemCreateEvent {
  ItemCreateEvent({
    this.after = Duration.zero,
    required this.next,
  });

  final Duration after;
  final _Model next;
}

class ItemListEvent {
  ItemListEvent(
    this.items, {
    this.after = Duration.zero,
  });

  final Duration after;
  final List<_Model> items;
}

LiveList<String, _Model> aLiveList({
  bool Function(_Model item) listenPredicate = _listenPredicate,
  bool Function(_Model) includePredicate = _includePredicate,
  String Function(_Model item) resolveId = _resolveId,
  Stream<List<_Model>>? itemStream,
  Stream<_Model> Function(String id)? onItemUpdated,
  Stream<_Model>? itemCreatedStream,
  List<ItemListEvent>? items,
  List<ItemUpdateEvent>? updates,
  List<ItemCreateEvent>? creates,
  Map<String? Function(_Model), Stream<void> Function(String)> Function(_Model item)? getDependencyStreams,
  FutureOr<_Model> Function(String id)? getItem,
  @Deprecated('NE') Map<String, List<(bool Function(_Model model), List<ItemTriggeringEvent>)>>? dependencyStreams,
}) {
  assert(
    onItemUpdated == null || updates == null,
    'Both onItemUpdated and updates can not be defined at the same time',
  );
  assert(
    itemCreatedStream == null || creates == null,
    'Both itemCreatedStream and creates can not be defined at the same time',
  );
  assert(
    itemStream == null || items == null,
    'Both itemStream and items can not be defined at the same time',
  );
  assert(
    getDependencyStreams == null || dependencyStreams == null,
    'Both getDependencyStreams and triggeringStream can not be defined at the same time',
  );
  final manualItemsStream = (items ?? []).map((e) => Future.delayed(e.after).then((value) => e.items));
  final effectiveItemStream = itemStream ?? Stream.fromFutures(manualItemsStream);

  final manualItemUpdateStream = (updates ?? [])
      .groupListsBy((item) => item.id)
      .map((key, value) => MapEntry(key, value.map((e) => Future.delayed(e.after).then((value) => e.next))));
  final effectiveOnItemUpdated = onItemUpdated ?? (id) => Stream.fromFutures(manualItemUpdateStream[id] ?? []);

  final manualItemCreatedStream = (creates ?? []).map((e) => Future.delayed(e.after).then((value) => e.next));
  final effectiveOnItemCreated = itemCreatedStream ?? Stream.fromFutures(manualItemCreatedStream);

  // Map<String, Stream<void>> _manualDependencyStreams(_Model model) {
  //   return (dependencyStreams ?? {}).map((key, value) {
  //     // final it = value.singleWhere(
  //     //   (element) {
  //     //     final match = element.$1(model);
  //     //     debugPrint('Match ${match ? "✅" : "❌"} of $model');
  //     //     return match;
  //     //   },
  //     //   orElse: () {
  //     //     debugPrint('❌❌ ${value.length}');
  //     //     assert(value.isNotEmpty, 'Multiple definitions match $model');
  //     //     return ((model) => false, []);
  //     //   },
  //     // ).$2;

  //     // final stream =
  //     //     it.isEmpty ? const Stream.empty() : Stream<void>.fromFutures(it.map((e) => Future.delayed(e.after)));

  //     final events = value.where((it) => it.$1(model)).firstOrNull?.$2 ?? [];
  //     final stream = events.isEmpty
  //         ? const Stream.empty()
  //         : Stream<void>.fromFutures(events.map((event) => Future.delayed(event.after)));
  //         debugPrint('________ $key returning $stream');

  //     return MapEntry(key, stream);
  //   });
  // }

  final effectiveGetDependencyStreams =
      getDependencyStreams /* ?? _manualDependencyStreams.when(dependencyStreams != null) */;

  return LiveList(
    itemListStream: effectiveItemStream,
    getItemUpdatedStream: effectiveOnItemUpdated,
    itemCreatedStream: effectiveOnItemCreated,
    resolveId: resolveId,
    listenPredicate: listenPredicate,
    includePredicate: includePredicate,
    getItem: getItem,
    getDependencyStreams: effectiveGetDependencyStreams,
  );
}

// class SequenceReturn<T extends Function> {
//   SequenceReturn({
//     required this.returnValues,
//   });

//   final List<T> returnValues;

//   int index = 0;

//   T getFn() {
//     if (index >= returnValues.length) {
//       return returnValues.last;
//     }
//     return returnValues[index++];
//   }
// }
class SequenceReturn<T> {
  SequenceReturn({
    required List<T> returnValues,
  }) : _returnValues = returnValues;

  final List<T> _returnValues;

  int index = 0;

  T getNextValue() {
    if (index >= _returnValues.length) {
      return _returnValues.last;
    }
    return _returnValues[index++];
  }

  List<T> getAll() => _returnValues;
}

void noOp() {}

class IncrmentalStream<T> {
  IncrmentalStream(this.streamMap);
  final Map<int, Stream<T>> streamMap;
  int listenCount = 0;

  Stream<T> get stream =>
      streamMap[listenCount]?.asBroadcastStream(
        onListen: (subscription) {
          listenCount++;
        },
      ) ??
      Stream<T>.empty();
}

void main() {
  group(
    'timeout',
    () {
      final disposableList = DisposableList();
      tearDown(() => disposableList.dispose());

      group('subscription', () {
        // test('Item update for a given id is only listened to once regardless of updates', () {
        //   final streamObserver = StreamObserver(Stream.fromIterable([aa, aaa]));
        //   disposableList.addDisposing(streamObserver.dispose);

        //   expect(
        //     aLiveList(
        //       items: [
        //         ItemListEvent([a, b]),
        //       ],
        //       onItemUpdated: (id) => id == a.id ? streamObserver.stream : const Stream.empty(),
        //     ).stream,
        //     emitsInOrder([
        //       [a, b],
        //       [aa, b],
        //       [aaa, b],
        //     ]),
        //   );
        //   expect(streamObserver.listenCount, emitsThrough(1));
        // });

        test('Item update for a given id is listened to again if it reappears', () {
          final sequenceReturn = SequenceReturn(
            returnValues: [
              StreamObserver(Stream.fromIterable([aa, aaa])),
              StreamObserver(Stream.fromFuture(Future.delayed(const Duration(seconds: 1)).then((_) => aaaa))),
            ],
          );

          final liveList = aLiveList(
            items: [
              ItemListEvent([a, b]),
              ItemListEvent([b], after: const Duration(milliseconds: 100)),
              ItemListEvent([a, b], after: const Duration(milliseconds: 200)),
            ],
            onItemUpdated: (id) {
              return id == a.id ? sequenceReturn.getNextValue().stream : const Stream.empty();
            },
          );
          disposableList.addDisposing(liveList.dispose);

          expect(
            liveList.stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [aaa, b],
              [b],
              [a, b],
              [aaaa, b],
            ]),
          );
          for (final s in sequenceReturn.getAll()) {
            expect(s.cancelCount, emits(1));
            expect(s.cancelCount, emitsDone);
          }
        });
      });

      group('itemStream', () {
        test('Emits initial items', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
            ).stream,
            emitsInOrder([
              [a, b],
            ]),
          );
        });
        test('Emits initial items then updated items', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent([a, bb], after: const Duration(milliseconds: 100)),
              ],
            ).stream,
            emitsInOrder([
              [a, b],
              [a, bb],
            ]),
          );
        });

        test('Emits initial items then individual item updates get superseeded by items update', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent([a, bb], after: const Duration(milliseconds: 200)),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 100), next: aa),
              ],
            ).stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [a, bb],
            ]),
          );
        });

        test('Emits initial items then individual item updates get ignored by item updates ', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent([b], after: const Duration(milliseconds: 100)),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 10), next: aa),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 20), next: aaa),
              ],
            ).stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [aaa, b],
              [b],
            ]),
          );
        });

        test('Emits initial items then subsequent items update ignore dropped out item', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent([a], after: const Duration(milliseconds: 100)),
              ],
              updates: [
                ItemUpdateEvent(id: b.id, after: const Duration(milliseconds: 200), next: bb),
                ItemUpdateEvent(id: b.id, after: const Duration(milliseconds: 300), next: bbb),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 400), next: aa),
              ],
            ).stream,
            emitsInOrder([
              [a, b],
              [a],
              [aa],
            ]),
          );
        });
      });

      group('onItemUpdate', () {
        test('Emits inital items then updates of items', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 100), next: aa),
                ItemUpdateEvent(id: b.id, after: const Duration(milliseconds: 200), next: bb),
              ],
            ).stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [aa, bb],
            ]),
          );
        });

        test('Emits inital items and multiple updates of same item', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 100), next: aa),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 200), next: aaa),
              ],
            ).stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [aaa, b],
            ]),
          );
        });
      });

      group('itemCreatedStream', () {
        test('Emits inital items and then new item', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 100), next: aa),
                ItemUpdateEvent(id: b.id, after: const Duration(milliseconds: 200), next: bb),
              ],
              creates: [
                ItemCreateEvent(after: const Duration(milliseconds: 300), next: c),
              ],
            ).stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [aa, bb],
              [aa, bb, c],
            ]),
          );
        });

        test('Emits inital items then new item then updates of new item', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 100), next: aa),
                ItemUpdateEvent(id: b.id, after: const Duration(milliseconds: 200), next: bb),
                ItemUpdateEvent(id: c.id, after: const Duration(milliseconds: 100), next: cc),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 500), next: aaa),
              ],
              creates: [
                ItemCreateEvent(after: const Duration(milliseconds: 300), next: c),
              ],
            ).stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [aa, bb],
              [aa, bb, c],
              [aa, bb, cc],
              [aaa, bb, cc],
            ]),
          );
        });
      });

      group('listenPredicate', () {
        test('Item is not listened to if listenPredicate returns false', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 100), next: aa),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 200), next: aaa),
                ItemUpdateEvent(id: b.id, after: const Duration(milliseconds: 300), next: bb),
              ],
              listenPredicate: (item) => item.id != 'a',
            ).stream,
            emitsInOrder([
              [a, b],
              [a, bb],
            ]),
          );
        });
        test('Item is eventually not listened to if listenPredicate returns false', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 100), next: aa),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 200), next: aaa),
                ItemUpdateEvent(id: b.id, after: const Duration(milliseconds: 300), next: bb),
              ],
              listenPredicate: (item) => item.name != 'AA',
            ).stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [aa, bb],
            ]),
          );
        });
        test('initially ignored item is listened to if predicate result changes', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent([aa, b], after: const Duration(milliseconds: 100)),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 200), next: aaa),
              ],
              listenPredicate: (item) => item.name != 'A',
            ).stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [aaa, b],
            ]),
          );
        });
        test('eventually ignored item is listened to if predicate result changes', () {
          final stream = IncrmentalStream<_Model>({
            0: Stream.fromFutures(
              [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 100), next: aa),
              ].map((e) => Future.delayed(e.after).then((value) => e.next)),
            ),
            1: Stream.fromFutures(
              [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 100), next: a),
              ].map((e) => Future.delayed(e.after).then((value) => e.next)),
            ),
          });

          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent([aaa, b], after: const Duration(milliseconds: 200)),
              ],
              onItemUpdated: (id) => id == a.id ? stream.stream : const Stream.empty(),
              listenPredicate: (item) => item.name != 'AA',
            ).stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [aaa, b],
              [a, b],
            ]),
          );
        });
      });

      group('includePredicate', () {
        test('Item is not included if includePredicate returns false', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              includePredicate: (item) => item.id != 'a',
            ).stream,
            emitsInOrder([
              [b],
            ]),
          );
        });
        test('previously not included item is still listened to and appears if gets included by item update', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 100), next: aa),
              ],
              includePredicate: (item) => item.name != 'A',
            ).stream,
            emitsInOrder([
              [b],
              [aa, b],
            ]),
          );
        });
        test('previously not included item is still listened to and appears if gets included by items update', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent([aa, b], after: const Duration(milliseconds: 100)),
              ],
              updates: [],
              includePredicate: (item) => item.name != 'A',
            ).stream,
            emitsInOrder([
              [b],
              [aa, b],
            ]),
          );
        });

        test('previously not included item is still listened to and appears when matches predicate', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent([aa, b], after: const Duration(milliseconds: 100)),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 200), next: aaa),
              ],
              includePredicate: (item) => item.name != 'A' && item.name != 'AA',
            ).stream,
            emitsInOrder([
              [b],
              [b],
              [aaa, b],
            ]),
          );
        });
      });
      group('addItem', () {
        test('adding an item results in listening for its updates', () async {
          final liveList = aLiveList(
            items: [
              ItemListEvent([a]),
            ],
            updates: [
              ItemUpdateEvent(id: b.id, after: const Duration(milliseconds: 100), next: bb),
              ItemUpdateEvent(id: b.id, after: const Duration(milliseconds: 200), next: bbb),
            ],
          );

          Future<void>.delayed(const Duration(milliseconds: 50)).then((value) => liveList.addItem(b));

          expect(
            liveList.stream,
            emitsInOrder([
              [a],
              [a, b],
              [a, bb],
              [a, bbb],
            ]),
          );
        });
      });
      group('removeItem', () {
        test('removing an item ignores updates', () async {
          final liveList = aLiveList(
            items: [
              ItemListEvent([a, b]),
            ],
            updates: [
              ItemUpdateEvent(id: b.id, after: const Duration(milliseconds: 100), next: bb),
              ItemUpdateEvent(id: b.id, after: const Duration(milliseconds: 200), next: bbb),
              ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 300), next: aa),
            ],
          );

          Future<void>.delayed(const Duration(milliseconds: 50)).then((value) => liveList.removeItem('b'));

          expect(
            liveList.stream,
            emitsInOrder([
              [a, b],
              [a],
              [aa],
            ]),
          );
        });
      });

      group('getDependencyStreams', () {
        test('should throw when getItem is not specified', () {
          expect(
            () => aLiveList(
              getDependencyStreams: (item) => {},
            ),
            throwsA(isA<ArgumentError>()),
          );
        });
        test('should not throw when getItem is also specified', () {
          expect(
            () => aLiveList(
              getDependencyStreams: (item) => {},
              getItem: (id) => Future.value(a),
            ),
            returnsNormally,
          );
        });
        test(
          'triggering stream should work if item matches predicate because of items',
          () async {
            final liveList = aLiveList(
              items: [
                ItemListEvent([aa]),
              ],
              getDependencyStreams: (item) {
                return {
                  (item) => item.foreignId: (foreignId) => foreignId == '2'
                      ? Stream.fromFuture(Future.delayed(const Duration(milliseconds: 100)))
                      : const Stream.empty(),
                };
              },
              getItem: (id) => aaa,
            );

            expect(
              liveList.stream,
              emitsInOrder([
                [aa],
                [aaa],
              ]),
            );
          },
        );
        test(
          'triggering stream should work if item matches predicate after item update',
          () async {
            final liveList = aLiveList(
              items: [
                ItemListEvent([a]),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 100), next: aa),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 200), next: aaa),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 300), next: aaaa),
              ],
              // dependencyStreams: {
              //   '3': [
              //     (
              //       (_Model model) => model.foreignId == '3',
              //       [
              //         ItemTriggeringEvent(after: const Duration(milliseconds: 400)),
              //       ],
              //     ),
              //   ],
              // },
              getDependencyStreams: (item) {
                return {
                  (item) => item.foreignId: (foreignId) => foreignId == '3'
                      ? Stream.fromFuture(Future.delayed(const Duration(milliseconds: 400)))
                      : const Stream.empty(),
                };
              },
              getItem: (id) => a,
            );

            expect(
              liveList.stream,
              emitsInOrder([
                [a],
                [aa],
                [aaa],
                [aaaa],
                [a],
              ]),
            );
          },
        );
        test(
          'triggering stream should 2',
          () async {
            final liveList = aLiveList(
              items: [
                ItemListEvent([aa]),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 10), next: aaa),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 10), next: aa),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 10), next: aaa),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 10), next: aa),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 10), next: aaa),
              ],
              dependencyStreams: {
                'a': [
                  (
                    (_Model model) => model.foreignId == '2',
                    [
                      ItemTriggeringEvent(after: const Duration(milliseconds: 300)),
                      ItemTriggeringEvent(after: const Duration(milliseconds: 600)),
                    ],
                  ),
                ],
              },
              getItem: (id) => a,
            );

            expect(
              liveList.stream,
              emitsInOrder([
                [aa],
                [aaa],
                [aa],
                [aaa],
                [aa],
                [aaa],
                [a],
                [a],
              ]),
            );
          },
        );
        test(
          'triggering stream should 3',
          () async {
            final liveList = aLiveList(
              items: [
                ItemListEvent([aa]),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 10), next: aaa),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 10), next: aa),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 10), next: aaa),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 10), next: aa),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 10), next: a),
                ItemUpdateEvent(id: a.id, after: const Duration(milliseconds: 500), next: aaaa),
              ],
              getDependencyStreams: (item) {
                return {
                  (item) => item.foreignId: (foreignId) => foreignId == '2'
                      ? Stream.fromFuture(Future.delayed(const Duration(milliseconds: 300)))
                      : const Stream.empty(),
                };
              },
              getItem: (id) {
                debugPrint('______ GET ITEM CALL');
                return a;
              },
            );

            expect(
              liveList.stream,
              emitsInOrder([
                [aa],
                [aaa],
                [aa],
                [aaa],
                [aa],
                [a],
                [aaaa],
              ]),
            );
          },
        );
      });
    },
    timeout: const Timeout(Duration(seconds: 3)),
  );
}

class _Model {
  const _Model({
    required this.id,
    required this.name,
    this.foreignId,
  });

  final String id;
  final String name;
  final String? foreignId;

  @override
  String toString() {
    return '_Model(id: $id, name: $name, foreignId: $foreignId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _Model && other.id == id && other.name == name && other.foreignId == foreignId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ foreignId.hashCode;
  }
}
