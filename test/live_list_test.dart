// ignore_for_file: unreachable_from_main

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:time/time.dart';
import 'package:v_flutter_core/src/utils/live_list.dart';

import 'stream_observer.dart';

const testLiveListsAreDisposedAfter = Duration(milliseconds: 900);
const testTimeoutAfter = Duration(milliseconds: 1000);

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

class TriggerEvent {
  TriggerEvent() : after = Duration.zero;
  TriggerEvent.after(this.after);

  final Duration after;
}

class ItemTriggerEvent {
  ItemTriggerEvent({
    required this.id,
  }) : after = Duration.zero;
  ItemTriggerEvent.after(
    this.after, {
    required this.id,
  });

  final String id;
  final Duration after;
}

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
  List<ItemTriggerEvent>? itemTriggers,
  TriggerStream Function(String id)? getItemTriggerStream,
  List<ItemEvent>? creates,
  FutureOr<List<(String? Function(_Model), TriggerStream Function(String))>> Function(_Model item)?
      getItemDependencyStreams,
  FutureOr<_Model> Function(String id)? fetchItem,
  Duration? disposeAfter = testLiveListsAreDisposedAfter,
  List<(String? Function(_Model item), List<(String, TriggerEvent)>)>? dependencyUpdates,
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
  assert(
    getItemTriggerStream == null || itemTriggers == null,
    'Both getItemTriggerStream and itemTriggers can not be defined at the same time',
  );
  assert(
    getItemDependencyStreams == null || dependencyUpdates == null,
    'Both getItemDependencyStreams and dependencyUpdates can not be defined at the same time',
  );
  final manualItemsStream = (items ?? []).map((e) => Future.delayed(e.after).then((value) => e.items));
  final effectiveItemStream = itemStream ?? Stream.fromFutures(manualItemsStream);

  final manualItemUpdateStream = (updates ?? [])
      .groupListsBy((item) => item.id)
      .map((key, value) => MapEntry(key, value.map((e) => Future.delayed(e.after).then((_) => e.item))));
  final effectiveOnItemUpdated = itemUpdatedStream ?? (id) => Stream.fromFutures(manualItemUpdateStream[id] ?? []);

  final manualItemCreatedStream = (creates ?? []).map((e) => Future.delayed(e.after).then((_) => e.item));
  final effectiveOnItemCreated = itemCreatedStream ?? Stream.fromFutures(manualItemCreatedStream);

  final manualItemIdUpdatedStream = (itemTriggers ?? [])
      .groupListsBy((item) => item.id)
      .map((key, value) => MapEntry(key, value.map((e) => Future.delayed(e.after).then((_) => e.id))));
  final effectiveItemTriggerStream = getItemTriggerStream ??
      ((itemTriggers?.isNotEmpty ?? false)
          ? (id) => Stream.fromFutures(manualItemIdUpdatedStream[id] ?? <Future<String>>[])
          : null);

  final effectiveGetItemDependencyStream = getItemDependencyStreams ??
      ((dependencyUpdates?.isNotEmpty ?? false)
          ? (_Model item) {
              return dependencyUpdates!
                  .map(
                    (e) => (
                      (_Model model) => e.$1(model),
                      (String id) {
                        final grouped = e.$2
                            .groupListsBy((trigger) => trigger.$1)
                            .map((key, value) => MapEntry(key, value.map((e) => e.$2)))
                            .map((key, value) => MapEntry(key, value.map((trigger) => Future.delayed(trigger.after))))
                            .map((key, value) => MapEntry(key, Stream.fromFuture(Future.wait(value).then((_) => id))));

                        return grouped[id] ?? const Stream.empty();
                      },
                    ),
                  )
                  .toList();
            }
          : null);

  final liveList = LiveList(
    itemListStream: effectiveItemStream,
    getItemUpdatedStream: effectiveOnItemUpdated,
    getItemTriggerStream: effectiveItemTriggerStream,
    itemCreatedStream: effectiveOnItemCreated,
    resolveId: resolveId,
    listenPredicate: listenPredicate,
    includePredicate: includePredicate,
    fetchItem: fetchItem != null ? (String id) => Future.sync(() => fetchItem(id)) : null,
    getItemDependencyStreams: effectiveGetItemDependencyStream,
  );
  if (disposeAfter != null) {
    Future.delayed(disposeAfter).then((_) => liveList.dispose());
  }
  addTearDown(liveList.dispose);
  return liveList;
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

  StreamObserver<void> thenTrigger() {
    return StreamObserver<void>(Stream.fromFuture(Future.delayed(this)));
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
                600.milliseconds.then(aaaa),
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
              // expect(s.doneCount, emits(1));
              // expect(s.doneCount, neverEmits(2));
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
                getItemDependencyStreams: (item) => [
                  (
                    (item) => item.foreignId,
                    (foreignId) => foreignId == '2' ? streamObserver.stream : const Stream.empty(),
                  ),
                ],
                fetchItem: (id) => a,
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
                disposeAfter: null,
                items: [
                  ItemListEvent([aa]),
                ],
                updates: [
                  ItemUpdateEvent.after(100.milliseconds, id: a.id, item: aaaa),
                ],
                getItemDependencyStreams: (item) => [
                  (
                    (item) => item.foreignId,
                    (foreignId) => foreignId == '2' ? streamObserver.stream : const Stream.empty(),
                  ),
                ],
                fetchItem: (id) => a,
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
              getItemDependencyStreams: (item) => [
                (
                  (item) => item.foreignId,
                  (foreignId) => foreignId == '2' ? streamObserver.stream : const Stream.empty(),
                ),
              ],
              fetchItem: (id) => a,
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
      group('itemTriggerStream event', () {
        test('fires items (with updated item) subsequently', () {
          final getA = SequenceReturn<_Model>(returnValues: [aa, aaa]);
          final getB = SequenceReturn<_Model>(returnValues: [bb, bbb]);
          _Model getNext(String id) => switch (id) {
                'a' => getA.next(),
                'b' => getB.next(),
                _ => throw 'No return defined for $id',
              };

          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              itemTriggers: [
                ItemTriggerEvent.after(100.milliseconds, id: a.id),
                ItemTriggerEvent.after(200.milliseconds, id: b.id),
                ItemTriggerEvent.after(300.milliseconds, id: a.id),
                ItemTriggerEvent.after(400.milliseconds, id: b.id),
              ],
              fetchItem: (id) => getNext(id),
            ).stream,
            emitsInOrder([
              [a, b],
              [aa, b],
              [aa, bb],
              [aaa, bb],
              [aaa, bbb],
            ]),
          );
        });

        test('have no effect after item is no longer present', () {
          final getA = SequenceReturn<_Model>(returnValues: [aa]);
          final getB = SequenceReturn<_Model>(returnValues: [bb, bbb]);
          _Model getNext(String id) => switch (id) {
                'a' => getA.next(),
                'b' => getB.next(),
                _ => throw 'No return defined for $id',
              };

          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
                ItemListEvent.after(200.milliseconds, [aaaa]),
              ],
              itemTriggers: [
                ItemTriggerEvent.after(100.milliseconds, id: b.id),
                ItemTriggerEvent.after(300.milliseconds, id: b.id),
                ItemTriggerEvent.after(400.milliseconds, id: a.id),
              ],
              fetchItem: (id) => getNext(id),
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
          final getA = SequenceReturn<_Model>(returnValues: [aa, aaa]);
          final getB = SequenceReturn<_Model>(returnValues: [bb]);
          final getC = SequenceReturn<_Model>(returnValues: [cc, ccc]);
          _Model getNext(String id) => switch (id) {
                'a' => getA.next(),
                'b' => getB.next(),
                'c' => getC.next(),
                _ => throw 'No return defined for $id',
              };

          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              itemTriggers: [
                ItemTriggerEvent.after(100.milliseconds, id: a.id),
                ItemTriggerEvent.after(200.milliseconds, id: b.id),
                // listening to c starts after it appears, that is why the durations are strange here
                ItemTriggerEvent.after(100.milliseconds, id: c.id), // this is esentially 300 + 100 here
                ItemTriggerEvent.after(200.milliseconds, id: c.id), // 300 + 200
                ItemTriggerEvent.after(600.milliseconds, id: a.id),
              ],
              creates: [
                ItemEvent.after(300.milliseconds, c),
              ],
              fetchItem: (id) => getNext(id),
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
          final getB = SequenceReturn<_Model>(returnValues: [bb, bbb]);
          _Model getNext(String id) => switch (id) {
                'b' => getB.next(),
                _ => throw 'No return defined for $id',
              };

          final liveList = aLiveList(
            items: [
              ItemListEvent([a]),
            ],
            itemTriggers: [
              ItemTriggerEvent.after(100.milliseconds, id: b.id),
              ItemTriggerEvent.after(200.milliseconds, id: b.id),
            ],
            fetchItem: (id) => getNext(id),
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

        group('deferItemIdUpdate', () {
          test('skips single id update', () {
            final getA = SequenceReturn<_Model>(returnValues: [aa]);

            final liveList = aLiveList(
              items: [
                ItemListEvent([a]),
              ],
              itemTriggers: [
                ItemTriggerEvent.after(100.milliseconds, id: a.id),
              ],
              fetchItem: (id) => getA.next(),
            );

            final completer = liveList.deferItemTrigger(a.id);
            Future<void>.delayed(300.milliseconds).then((value) => completer.completeAwaitingHandshake(aaaa));

            expect(
              liveList.stream,
              emitsInOrder([
                [a],
                [aaaa],
              ]),
            );
          });

          test('skips every id update', () {
            final getA = SequenceReturn<_Model>(returnValues: [aa, aaa]);

            final liveList = aLiveList(
              items: [
                ItemListEvent([a]),
              ],
              itemTriggers: [
                ItemTriggerEvent.after(100.milliseconds, id: a.id),
                ItemTriggerEvent.after(200.milliseconds, id: a.id),
              ],
              fetchItem: (id) => getA.next(),
            );

            final completer = liveList.deferItemTrigger(a.id);
            Future<void>.delayed(300.milliseconds).then((value) => completer.completeAwaitingHandshake(aaaa));

            expect(
              liveList.stream,
              emitsInOrder([
                [a],
                [aaaa],
              ]),
            );
          });

          test('skips singular update while deferring', () {
            final getA = SequenceReturn<_Model>(returnValues: [aa]);

            final liveList = aLiveList(
              items: [
                ItemListEvent([a]),
              ],
              itemTriggers: [
                ItemTriggerEvent.after(20.milliseconds, id: a.id),
              ],
              fetchItem: (id) => getA.next(),
            );

            final completer = liveList.deferItemTrigger(a.id);
            Future<void>.delayed(100.milliseconds).then((value) => completer.completeAwaitingHandshake(aaaa));

            expect(
              liveList.stream,
              emitsInOrder([
                [a],
                [aaaa],
              ]),
            );
            expect(liveList.stream, neverEmits([aa]));
          });

          test('calls fetchItem once when multiple updates fired while deferring', () {
            final getA = SequenceReturn<_Model>(returnValues: [aa, aaa]);

            final liveList = aLiveList(
              items: [
                ItemListEvent([a]),
              ],
              itemTriggers: [
                ItemTriggerEvent.after(20.milliseconds, id: a.id),
                ItemTriggerEvent.after(40.milliseconds, id: a.id),
                ItemTriggerEvent.after(60.milliseconds, id: a.id),
                ItemTriggerEvent.after(80.milliseconds, id: a.id),
                ItemTriggerEvent.after(100.milliseconds, id: a.id),
                ItemTriggerEvent.after(120.milliseconds, id: a.id),
                ItemTriggerEvent.after(140.milliseconds, id: a.id),
              ],
              fetchItem: (id) {
                return getA.next();
              },
            );

            final completer = liveList.deferItemTrigger(a.id);
            Future<void>.delayed(200.milliseconds).then((value) => completer.completeAwaitingHandshake(aaaa));

            expect(
              liveList.stream,
              emitsInOrder([
                [a],
                [aaaa],
                [aa],
              ]),
            );
            expect(liveList.stream, neverEmits([aaa]));
          });

          test('does not skip update if completer fails', () {
            final getA = SequenceReturn<_Model>(returnValues: [aa]);

            final liveList = aLiveList(
              items: [
                ItemListEvent([a]),
              ],
              itemTriggers: [
                ItemTriggerEvent.after(50.milliseconds, id: a.id),
              ],
              fetchItem: (id) => getA.next(),
            );

            final completer = liveList.deferItemTrigger(a.id);
            Future<void>.delayed(100.milliseconds).then((value) => completer.completeError('NOPE'));

            expect(
              liveList.stream,
              emitsInOrder([
                [a],
                [aa],
              ]),
            );
          });
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
        test('item dependencies are ignored', () {
          expect(
            aLiveList(
              items: [
                ItemListEvent([a, b]),
              ],
              dependencyUpdates: [
                (
                  (item) => item.foreignId,
                  [('1', TriggerEvent.after(50.milliseconds))],
                ),
              ],
              fetchItem: (id) => aaaa,
              listenPredicate: (item) => item.id != a.id,
            ).stream,
            neverEmits([aaaa, b]),
          );
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
      group('addItem', () {
        test('adds item', () {
          final liveList = aLiveList(
            items: [
              ItemListEvent([a]),
            ],
            updates: [
              ItemUpdateEvent.after(10.milliseconds, id: a.id, item: aa),
              ItemUpdateEvent.after(20.milliseconds, id: a.id, item: aaa),
            ],
          );

          Future<void>.delayed(100.milliseconds).then((value) => liveList.addItem(b));

          expect(
            liveList.stream,
            emitsInOrder([
              [a],
              [aa],
              [aaa],
              [aaa, b],
            ]),
          );
        });
        test('overrides individual item update (update)', () {
          final liveList = aLiveList(
            items: [
              ItemListEvent([a, b]),
              ItemListEvent.after(50.milliseconds, [a, bb]),
            ],
          );

          Future<void>.delayed(100.milliseconds).then((value) => liveList.addItem(b));

          expect(
            liveList.stream,
            emitsInOrder([
              [a, b],
              [a, bb],
              [a, b],
            ]),
          );
        });
      });
      group('removeItem', () {
        test('subsequent item updates are ignored', () async {
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

        test('itemUpdated stream is unsubscribed from before it emits', () async {
          final streamObserver = 200.milliseconds.then(aa);

          final liveList = aLiveList(
            items: [
              ItemListEvent([a]),
            ],
            itemUpdatedStream: (id) {
              return id == a.id ? streamObserver.stream : const Stream.empty();
            },
          );

          Future<void>.delayed(const Duration(milliseconds: 100)).then((value) => liveList.removeItem('a'));

          expect(
            liveList.stream,
            neverEmits([
              [aa],
            ]),
          );
          expect(streamObserver.emitCount, neverEmits(1));
          expect(streamObserver.listenCount, emits(1));
          expect(streamObserver.listenCount, neverEmits(2));
          expect(streamObserver.cancelCount, emits(1));
          expect(streamObserver.cancelCount, neverEmits(2));
        });

        test('item dependencies are unsubscribed from', () async {
          final streamObserver = 200.milliseconds.thenTrigger();

          final liveList = aLiveList(
            items: [
              ItemListEvent([a]),
            ],
            getItemDependencyStreams: (item) => [
              (
                (item) => item.foreignId,
                (foreignId) => foreignId == '1' ? streamObserver.stream : const Stream.empty(),
              ),
            ],
            fetchItem: (id) => aa,
          );

          Future<void>.delayed(const Duration(milliseconds: 100)).then((value) => liveList.removeItem('a'));

          expect(
            liveList.stream,
            neverEmits([
              [aa],
            ]),
          );
          expect(streamObserver.emitCount, neverEmits(1));
          expect(streamObserver.listenCount, emits(1));
          expect(streamObserver.listenCount, neverEmits(2));
          expect(streamObserver.cancelCount, emits(1));
          expect(streamObserver.cancelCount, neverEmits(2));
        });
      });

      group('getItemDependencyStreams', () {
        test('should throw when fetchItem is not specified', () {
          expect(
            () => aLiveList(
              getItemDependencyStreams: (item) => [],
            ),
            throwsA(isA<ArgumentError>()),
          );
        });
        test('should not throw when fetchItem is also specified', () {
          expect(
            () => aLiveList(
              getItemDependencyStreams: (item) => [],
              fetchItem: (id) => Future.value(a),
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
              dependencyUpdates: [
                (
                  (item) => item.foreignId,
                  [('2', TriggerEvent.after(100.milliseconds))],
                ),
              ],
              fetchItem: (id) => aaa,
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
              dependencyUpdates: [
                (
                  (item) => item.foreignId!,
                  [('3', TriggerEvent())],
                ),
              ],
              fetchItem: (id) => a,
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
          'triggering stream should work if item matches predicate after item update triggered by dependency',
          () async {
            final fetchItem = SequenceReturn<_Model Function(String)>(returnValues: [(_) => aa, (_) => aaaa]);

            final liveList = aLiveList(
              items: [
                ItemListEvent([a]),
              ],
              dependencyUpdates: [
                (
                  (item) => item.foreignId,
                  [
                    ('1', TriggerEvent.after(100.milliseconds)),
                    ('2', TriggerEvent.after(100.milliseconds)),
                  ],
                ),
              ],
              fetchItem: (id) => fetchItem.next()(id),
            );

            expect(
              liveList.stream,
              emitsInOrder([
                [a],
                [aa],
                [aaaa],
              ]),
            );
          },
        );
      });
      // group('updateDelegates', () {
      //   test('should throw when neither getItemTriggerStream nor fetchItem are not specified', () {
      //     final liveList = aLiveList();

      //     expect(
      //       () => liveList.deferItemTrigger('a'),
      //       throwsA(isA<ArgumentError>()),
      //     );
      //   });
      //   test('should throw when getItemTriggerStream is not specified', () {
      //     final liveList = aLiveList(fetchItem: (_) => a);

      //     expect(
      //       () => liveList.deferItemTrigger('a'),
      //       throwsA(isA<ArgumentError>()),
      //     );
      //   });
      //   test('should not throw when both getItemTriggerStream fetchItem are specified', () {
      //     final liveList = aLiveList(
      //       fetchItem: (id) => a,
      //       getItemTriggerStream: (_) => const Stream.empty(),
      //     );

      //     expect(
      //       () => liveList.deferItemTrigger('a'),
      //       returnsNormally,
      //     );
      //   });
      //   test('should update item', () async {
      //     final liveList = aLiveList(
      //       items: [
      //         ItemListEvent([a, b]),
      //         // ItemListEvent.after(50.milliseconds, [aa, b]),
      //       ],
      //       fetchItem: (id) => aaa,
      //       getItemTriggerStream: (_) => const Stream.empty(),
      //     );

      //     final completer = liveList.deferItemTrigger('a');
      //     await Future<void>.delayed(100.milliseconds).then((value) => completer.complete(aaaa));

      //     expectLater(
      //       liveList.stream,
      //       emitsInOrder(
      //         [
      //           [a, b],
      //           // [aa, b],
      //           [aaaa, b],
      //         ],
      //       ),
      //     );
      //   });
      // });
    },
    timeout: const Timeout(testTimeoutAfter),
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

extension _DurationX on Duration {
  Stream<void> get asStream => Stream<void>.fromFuture(Future.delayed(this));
}
