// ignore_for_file: unreachable_from_main

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:time/time.dart';
import 'package:v_flutter_core/src/utils/live_list.dart';

import 'stream_observer.dart';

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
    required this.item,
  }) : after = Duration.zero;
  ItemUpdateEvent.after(
    this.after, {
    required this.id,
    required this.item,
  });

  final String id;
  final Duration after;
  final _Model item;
}

class ItemEvent {
  ItemEvent(this.item) : after = Duration.zero;
  ItemEvent.after(this.after, this.item);

  final Duration after;
  final _Model item;
}

class ItemListEvent {
  ItemListEvent(this.items) : after = Duration.zero;
  ItemListEvent.after(this.after, this.items);

  final Duration after;
  final List<_Model> items;
}

LiveList<String, _Model> aLiveList({
  bool Function(_Model item) listenPredicate = _listenPredicate,
  bool Function(_Model) includePredicate = _includePredicate,
  String Function(_Model item) resolveId = _resolveId,
  Stream<List<_Model>>? itemStream,
  Stream<_Model> Function(String id)? itemUpdatedStream,
  Stream<_Model>? itemCreatedStream,
  List<ItemListEvent>? items,
  List<ItemUpdateEvent>? updates,
  List<ItemEvent>? creates,
  List<(String? Function(_Model), Stream<void> Function(String))> Function(_Model item)? getDependencyStreams,
  FutureOr<_Model> Function(String id)? getItem,
}) {
  assert(
    itemUpdatedStream == null || updates == null,
    'Both itemUpdatedStream and updates can not be defined at the same time',
  );
  assert(
    itemCreatedStream == null || creates == null,
    'Both itemCreatedStream and creates can not be defined at the same time',
  );
  assert(
    itemStream == null || items == null,
    'Both itemStream and items can not be defined at the same time',
  );
  final manualItemsStream = (items ?? []).map((e) => Future.delayed(e.after).then((value) => e.items));
  final effectiveItemStream = itemStream ?? Stream.fromFutures(manualItemsStream);

  final manualItemUpdateStream = (updates ?? [])
      .groupListsBy((item) => item.id)
      .map((key, value) => MapEntry(key, value.map((e) => Future.delayed(e.after).then((value) => e.item))));
  final effectiveOnItemUpdated = itemUpdatedStream ?? (id) => Stream.fromFutures(manualItemUpdateStream[id] ?? []);

  final manualItemCreatedStream = (creates ?? []).map((e) => Future.delayed(e.after).then((value) => e.item));
  final effectiveOnItemCreated = itemCreatedStream ?? Stream.fromFutures(manualItemCreatedStream);

  final list = LiveList(
    itemListStream: effectiveItemStream,
    getItemUpdatedStream: effectiveOnItemUpdated,
    itemCreatedStream: effectiveOnItemCreated,
    resolveId: resolveId,
    listenPredicate: listenPredicate,
    includePredicate: includePredicate,
    getItem: getItem,
    getDependencyStreams: getDependencyStreams,
  );
  addTearDown(list.dispose);
  return list;
}

class SequenceReturn<T> {
  SequenceReturn({
    required List<T> returnValues,
  }) : _returnValues = returnValues;

  final List<T> _returnValues;

  int index = 0;

  T next() {
    if (index >= _returnValues.length) {
      throw 'No value set for the #$index call';
    }
    return _returnValues[index++];
  }

  List<T> getAll() => _returnValues;
}

void noOp() {}

extension _I<T> on List<T> {
  StreamObserver<T> get streamObserver {
    return StreamObserver(this.stream);
  }

  Stream<T> get stream {
    return Stream.fromIterable(this);
  }
}

extension _D on Duration {
  StreamObserver<T> then<T>(T item) {
    return StreamObserver<T>(Stream.fromFuture(Future.delayed(this).then((_) => item)));
  }
}

void main() {
  group(
    'timeout',
    () {
      // note that `aLiveList` calls `addTearDown(list.dispose);` internally
      group('subscription', () {
        group('itemListStream', () {
          test('is listened to once and is unsubscribed from', () async {
            final streamObserver = [
              [a],
              [aa],
              [aaa],
            ].streamObserver;

            expect(
              aLiveList(
                itemStream: streamObserver.stream,
                updates: [
                  ItemUpdateEvent.after(200.milliseconds, id: a.id, item: aaaa),
                  ItemUpdateEvent.after(200.milliseconds, id: a.id, item: aaa),
                ],
              ).stream,
              emitsInOrder([
                [a],
                [aa],
                [aaa],
                [aaaa],
                [aaa],
              ]),
            );
            expect(streamObserver.listenCount, emits(1));
            expect(streamObserver.listenCount, neverEmits(2));
            expect(streamObserver.cancelCount, emits(1));
            expect(streamObserver.cancelCount, neverEmits(2));
            expect(streamObserver.doneCount, emits(1));
            expect(streamObserver.doneCount, neverEmits(2));
          });
        });

        group('itemUpdatedStream', () {
          test('is listened to once and is unsubscribed from', () async {
            final streamObserver = [aa, aaa].streamObserver;

            expect(
              aLiveList(
                items: [
                  ItemListEvent([a, b]),
                  ItemListEvent.after(100.milliseconds, [aaaa, b]),
                  ItemListEvent.after(200.milliseconds, [aaa, b]),
                ],
                itemUpdatedStream: (id) => id == a.id ? streamObserver.stream : const Stream.empty(),
              ).stream,
              emitsInOrder([
                [a, b],
                [aa, b],
                [aaa, b],
                [aaaa, b],
                [aaa, b],
              ]),
            );
            expect(streamObserver.listenCount, emits(1));
            expect(streamObserver.listenCount, neverEmits(2));
            expect(streamObserver.cancelCount, emits(1));
            expect(streamObserver.cancelCount, neverEmits(2));
            expect(streamObserver.doneCount, emits(1));
            expect(streamObserver.doneCount, neverEmits(2));
          });

          test('is get and listened to again when item reappears', () {
            final sequenceReturn = SequenceReturn<StreamObserver<_Model>>(
              returnValues: [
                [aa, aaa].streamObserver,
                1.seconds.then(aaaa),
              ],
            );

            expect(
              aLiveList(
                items: [
                  ItemListEvent([a, b]),
                  ItemListEvent.after(100.milliseconds, [b]),
                  ItemListEvent.after(200.milliseconds, [a, b]),
                ],
                itemUpdatedStream: (id) {
                  return id == a.id ? sequenceReturn.next().stream : const Stream.empty();
                },
              ).stream,
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
              expect(s.cancelCount, neverEmits(2));
              expect(s.doneCount, emits(1));
              expect(s.doneCount, neverEmits(2));
            }
          });

          test('is not listened to at all when listenPredicate is false', () async {
            final streamObserver = [aa, aaa].streamObserver;

            await expectLater(
              aLiveList(
                items: [
                  ItemListEvent([a]),
                ],
                listenPredicate: (item) => item.id != a.id,
                itemUpdatedStream: (id) => id == a.id ? streamObserver.stream : const Stream.empty(),
              ).stream,
              emitsInOrder([
                [a],
              ]),
            );
            streamObserver.dispose();
            expect(streamObserver.listenCount, neverEmits(anything));
            expect(streamObserver.cancelCount, neverEmits(anything));
            expect(streamObserver.doneCount, neverEmits(anything));
          });
        });
        group('itemCreatedStream', () {
          test('is listened to once and is unsubscribed from', () async {
            final streamObserver = [b].streamObserver;

            await expectLater(
              aLiveList(
                items: [
                  ItemListEvent.after(100.milliseconds, [a]),
                ],
                updates: [
                  ItemUpdateEvent.after(200.milliseconds, id: a.id, item: aa),
                ],
                itemCreatedStream: streamObserver.stream,
              ).stream,
              emitsInOrder([
                [b],
                [a],
                [aa],
              ]),
            );
            expect(streamObserver.listenCount, emits(1));
            expect(streamObserver.listenCount, neverEmits(2));
            expect(streamObserver.cancelCount, emits(1));
            expect(streamObserver.cancelCount, neverEmits(2));
            expect(streamObserver.doneCount, emits(1));
            expect(streamObserver.doneCount, neverEmits(2));
          });
        });
        group('dependencyStream', () {
          test(
            'although item updates frequently, dependency stream is only listened to once',
            () async {
              final streamObserver = 300.milliseconds.then(null);

              final liveList = aLiveList(
                items: [
                  ItemListEvent([aa]),
                ],
                updates: [
                  ItemUpdateEvent.after(10.milliseconds, id: a.id, item: aaa),
                  ItemUpdateEvent.after(20.milliseconds, id: a.id, item: aa),
                  ItemUpdateEvent.after(30.milliseconds, id: a.id, item: aaa),
                  ItemUpdateEvent.after(40.milliseconds, id: a.id, item: aa),
                  ItemUpdateEvent.after(50.milliseconds, id: a.id, item: aaa),
                ],
                getDependencyStreams: (item) => [
                  (
                    (item) => item.foreignId,
                    (foreignId) => foreignId == '2' ? streamObserver.stream : const Stream.empty(),
                  ),
                ],
                getItem: (id) => a,
              );

              await expectLater(
                liveList.stream,
                emitsInOrder([
                  [aa],
                  [aaa],
                  [aa],
                  [aaa],
                  [aa],
                  [aaa],
                  [a],
                ]),
              );
              expect(streamObserver.listenCount, emits(1));
              expect(streamObserver.cancelCount, emits(1));
            },
          );
          test(
            'cancelled without any emits when it is no longer relevant',
            () async {
              final streamObserver = 300.milliseconds.then(null);

              final liveList = aLiveList(
                items: [
                  ItemListEvent([aa]),
                ],
                updates: [
                  ItemUpdateEvent.after(100.milliseconds, id: a.id, item: aaaa),
                ],
                getDependencyStreams: (item) => [
                  (
                    (item) => item.foreignId,
                    (foreignId) => foreignId == '2' ? streamObserver.stream : const Stream.empty(),
                  ),
                ],
                getItem: (id) => a,
              );

              await expectLater(
                liveList.stream,
                emitsInOrder([
                  [aa],
                  [aaaa],
                ]),
              );
              expect(streamObserver.emitCount, neverEmits(anything));
              expect(streamObserver.listenCount, emits(1));
              expect(streamObserver.cancelCount, emits(1));
              streamObserver.dispose();
            },
          );
          test('is not listened to at all when listenPredicate is false', () async {
            final streamObserver = 100.milliseconds.then(null);

            final liveList = aLiveList(
              items: [
                ItemListEvent([aa]),
              ],
              getDependencyStreams: (item) => [
                (
                  (item) => item.foreignId,
                  (foreignId) => foreignId == '2' ? streamObserver.stream : const Stream.empty(),
                ),
              ],
              getItem: (id) => a,
              listenPredicate: (item) => item.id != a.id,
            );

            expect(
              liveList.stream,
              emitsInOrder([
                [aa],
              ]),
            );
            expect(streamObserver.emitCount, neverEmits(anything));
            expect(streamObserver.listenCount, neverEmits(anything));
            expect(streamObserver.cancelCount, neverEmits(anything));
            streamObserver.dispose();
          });
        });
      });

      group('itemListStream event', () {
        test('fires exact same items subsequently', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent.after(100.milliseconds, [a, bb]),
                ItemListEvent.after(200.milliseconds, [aa, bb]),
              ],
            ).stream,
            emitsInOrder([
              [a, b],
              [a, bb],
              [aa, bb],
            ]),
          );
        });

        test('overrides individual item update (update)', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent.after(200.milliseconds, [a, bb]),
              ],
              updates: [
                ItemUpdateEvent.after(100.milliseconds, id: a.id, item: aa),
              ],
            ).stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [a, bb],
            ]),
          );
        });

        test('overrides individual item update (remove)', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent.after(100.milliseconds, [b]),
              ],
              updates: [
                ItemUpdateEvent.after(10.milliseconds, id: a.id, item: aa),
                ItemUpdateEvent.after(20.milliseconds, id: a.id, item: aaa),
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
      });

      group('itemUpdatedStream event', () {
        test('fires items (with updated item) subsequently', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              updates: [
                ItemUpdateEvent.after(100.milliseconds, id: a.id, item: aa),
                ItemUpdateEvent.after(200.milliseconds, id: b.id, item: bb),
              ],
            ).stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [aa, bb],
            ]),
          );
        });

        test('have no effect after item is no longer present', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent.after(200.milliseconds, [aaaa]),
              ],
              updates: [
                ItemUpdateEvent.after(100.milliseconds, id: b.id, item: bb),
                ItemUpdateEvent.after(300.milliseconds, id: b.id, item: bbb),
                ItemUpdateEvent.after(400.milliseconds, id: a.id, item: aa),
              ],
            ).stream,
            emitsInOrder([
              [a, b],
              [a, bb],
              [aaaa],
              [aa],
            ]),
          );
        });

        test('of newly created item fires items (with updated item) subsequently', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              updates: [
                ItemUpdateEvent.after(100.milliseconds, id: a.id, item: aa),
                ItemUpdateEvent.after(200.milliseconds, id: b.id, item: bb),
                // listening to c starts after it appears, that is why the durations are strange here
                ItemUpdateEvent.after(100.milliseconds, id: c.id, item: cc), // this is esentially 300 + 100 here
                ItemUpdateEvent.after(200.milliseconds, id: c.id, item: ccc), // 300 + 200
                ItemUpdateEvent.after(600.milliseconds, id: a.id, item: aaa),
              ],
              creates: [
                ItemEvent.after(300.milliseconds, c),
              ],
            ).stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [aa, bb],
              [aa, bb, c],
              [aa, bb, cc],
              [aa, bb, ccc],
              [aaa, bb, ccc],
            ]),
          );
        });
        test('of explicitly added item fires items (with updated item) subsequently', () async {
          final liveList = aLiveList(
            items: [
              ItemListEvent([a]),
            ],
            updates: [
              ItemUpdateEvent.after(100.milliseconds, id: b.id, item: bb),
              ItemUpdateEvent.after(200.milliseconds, id: b.id, item: bbb),
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

      group('itemCreatedStream event', () {
        test('fires items (with new item) subsequently', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a]),
              ],
              updates: [
                ItemUpdateEvent.after(100.milliseconds, id: a.id, item: aa),
                ItemUpdateEvent.after(200.milliseconds, id: a.id, item: aaa),
              ],
              creates: [
                ItemEvent.after(300.milliseconds, b),
                ItemEvent.after(400.milliseconds, c),
              ],
            ).stream,
            emitsInOrder([
              [a],
              [aa],
              [aaa],
              [aaa, b],
              [aaa, b, c],
            ]),
          );
        });

        test('of existing item (invalid) acts as an itemUpdate event', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a]),
              ],
              creates: [
                ItemEvent.after(100.milliseconds, aa),
                ItemEvent.after(200.milliseconds, aaa),
              ],
            ).stream,
            emitsInOrder([
              [a],
              [aa],
              [aaa],
            ]),
          );
        });
      });

      group('when listenPredicate is false', () {
        test('individual item update is ignored', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              updates: [
                ItemUpdateEvent.after(100.milliseconds, id: a.id, item: aa),
                ItemUpdateEvent.after(200.milliseconds, id: a.id, item: aaa),
                ItemUpdateEvent.after(300.milliseconds, id: b.id, item: bb),
              ],
              listenPredicate: (item) => item.id != a.id,
            ).stream,
            emitsInOrder([
              [a, b],
              [a, bb],
            ]),
          );
        });
        test('individual item update is eventually ignored after listenPredicate becomes false', () async {
          final aStream = [aa, aaa].streamObserver;
          final bStream = 300.milliseconds.then(bb);

          final liveList = aLiveList(
            items: [
              ItemListEvent([a, b]),
            ],
            itemUpdatedStream: (id) => switch (id) {
              'a' => aStream.stream,
              'b' => bStream.stream,
              _ => const Stream.empty() //
            },
            listenPredicate: (item) => item.name != 'AA',
          );

          await expectLater(
            liveList.stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [aa, bb],
            ]),
          );
          // TOTO assert aStream is done before [aa, bb]
        });
        test('initially ignored item is listened to after listenPredicate result changes via items update', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent.after(100.milliseconds, [aa, b]),
              ],
              updates: [
                ItemUpdateEvent(id: a.id, item: aaa),
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
        test('eventually ignored item is listened to again after listenPredicate result changes via items update',
            () async {
          final first = [aa].streamObserver;
          final second = [a].streamObserver;

          final sequenceReturn = SequenceReturn<StreamObserver<_Model>>(
            returnValues: [first, second],
          );

          final liveList = aLiveList(
            items: [
              ItemListEvent([a, b]),
              ItemListEvent.after(200.milliseconds, [aaa, b]),
            ],
            itemUpdatedStream: (id) => id == a.id ? sequenceReturn.next().stream : const Stream.empty(),
            listenPredicate: (item) => item.name != 'AA',
          );
          await expectLater(
            liveList.stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [aaa, b],
            ]),
          );
          await expectLater(first.cancelCount, emits(1));
          await expectLater(
            liveList.stream,
            emitsInOrder([
              [a, b],
            ]),
          );
          await expectLater(second.cancelCount, emits(1));
        });
      });

      group('when includePredicate is false', () {
        test('item is not included', () {
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
        test(
            'initially not included item is still listened to and appears after includedPredicate becomes true by item update',
            () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              updates: [
                ItemUpdateEvent.after(100.milliseconds, id: a.id, item: aa),
              ],
              includePredicate: (item) => item.name != 'A',
            ).stream,
            emitsInOrder([
              [b],
              [aa, b],
            ]),
          );
        });
        test(
            'initially not included item is still listened to and appears after includedPredicate becomes true by item update',
            () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent.after(100.milliseconds, [aa, b]),
              ],
              includePredicate: (item) => item.name != 'A',
            ).stream,
            emitsInOrder([
              [b],
              [aa, b],
            ]),
          );
        });

        test(
            'previously not included item is still listened to and appears after includedPredicate becomes true by item update',
            () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              updates: [
                ItemUpdateEvent.after(100.milliseconds, id: a.id, item: aa),
                ItemUpdateEvent.after(200.milliseconds, id: a.id, item: aaa),
              ],
              includePredicate: (item) => item.name != 'AA',
            ).stream,
            emitsInOrder([
              [a, b],
              [b],
              [aaa, b],
            ]),
          );
        });
        test('eventually not included item appears after includedPredicate becomes true by item update', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent.after(100.milliseconds, [aa, b]),
                ItemListEvent.after(200.milliseconds, [aaa, b]),
              ],
              includePredicate: (item) => item.name != 'AA',
            ).stream,
            emitsInOrder([
              [a, b],
              [b],
              [aaa, b],
            ]),
          );
        });
      });
      group('addItem', () {});
      group('removeItem', () {
        test('removing an item ignores updates', () async {
          final liveList = aLiveList(
            items: [
              ItemListEvent([a, b]),
            ],
            updates: [
              ItemUpdateEvent.after(100.milliseconds, id: b.id, item: bb),
              ItemUpdateEvent.after(200.milliseconds, id: b.id, item: bbb),
              ItemUpdateEvent.after(300.milliseconds, id: a.id, item: aa),
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
              getDependencyStreams: (item) => [],
            ),
            throwsA(isA<ArgumentError>()),
          );
        });
        test('should not throw when getItem is also specified', () {
          expect(
            () => aLiveList(
              getDependencyStreams: (item) => [],
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
                return [
                  (
                    (item) => item.foreignId,
                    (foreignId) => foreignId == '2'
                        ? Stream.fromFuture(Future.delayed(const Duration(milliseconds: 100)))
                        : const Stream.empty()
                  ),
                ];
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
                ItemUpdateEvent.after(100.milliseconds, id: a.id, item: aa),
                ItemUpdateEvent.after(200.milliseconds, id: a.id, item: aaa),
                ItemUpdateEvent.after(300.milliseconds, id: a.id, item: aaaa),
              ],
              getDependencyStreams: (item) {
                return [
                  (
                    (item) => item.foreignId,
                    (foreignId) => foreignId == '3' ? Stream.value(null) : const Stream.empty(),
                  ),
                ];
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
