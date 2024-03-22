// ignore_for_file: unreachable_from_main

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:v_flutter_core/src/utils/live_list_copy.dart';

const a = _Model(id: 'a', name: 'A');
const aa = _Model(id: 'a', name: 'AA');
const aaa = _Model(id: 'a', name: 'AAA');
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
  final manualItemsStream = (items ?? []).map((e) => Future.delayed(e.after).then((value) => e.items));
  final effectiveItemStream = itemStream ?? Stream.fromFutures(manualItemsStream);

  final manualItemUpdateStream = (updates ?? [])
      .groupListsBy((item) => item.id)
      .map((key, value) => MapEntry(key, value.map((e) => Future.delayed(e.after).then((value) => e.next))));
  final effectiveOnItemUpdated = onItemUpdated ?? (id) => Stream.fromFutures(manualItemUpdateStream[id] ?? []);

  final manualItemCreatedStream = (creates ?? []).map((e) => Future.delayed(e.after).then((value) => e.next));
  final effectiveOnItemCreated = itemCreatedStream ?? Stream.fromFutures(manualItemCreatedStream);

  return LiveList(
    itemListStream: effectiveItemStream,
    getItemUpdatedStream: effectiveOnItemUpdated,
    itemCreatedStream: effectiveOnItemCreated,
    resolveId: resolveId,
    listenPredicate: listenPredicate,
    includePredicate: includePredicate,
  );
}

class ListenCounterStream<T> {
  ListenCounterStream(this._stream);
  final Stream<T> _stream;
  int _listenCount = 0;

  Stream<T> get stream => _stream.asBroadcastStream(
        onListen: (subscription) {
          _listenCount++;
        },
      );

  int get listenCount => _listenCount;
}

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
  group('subscription', () {
    test('Item update for a given id is only listened to once regardless of updates', () {
      final listenCounterStream = ListenCounterStream(Stream.fromIterable([aa, aaa]));

      expect(
        aLiveList(
          items: [
            ItemListEvent([a, b]),
          ],
          onItemUpdated: (id) => id == a.id ? listenCounterStream.stream : const Stream.empty(),
        ).stream,
        emitsInOrder([
          [a, b],
          [aa, b],
          [aaa, b],
        ]),
      );
      equals(listenCounterStream.listenCount, 1);
    });

    test('Item update for a given id is listened to again if it reappears', () {
      final listenCounterStream = ListenCounterStream(Stream.fromIterable([aa, aaa]));

      expect(
        aLiveList(
          items: [
            ItemListEvent([a, b]),
            ItemListEvent([b], after: const Duration(milliseconds: 100)),
            ItemListEvent([a, b], after: const Duration(milliseconds: 200)),
          ],
          onItemUpdated: (id) => id == a.id ? listenCounterStream.stream : const Stream.empty(),
        ).stream,
        emitsInOrder([
          [a, b],
          [aa, b],
          [aaa, b],
          [b],
          [a, b],
          [aa, b], // this
          [aaa, b], // and this is just test setup lacking
        ]),
      );
      equals(listenCounterStream.listenCount, 2);
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
}

class _Model {
  const _Model({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  String toString() {
    return '_Model(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _Model && other.id == id && other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }
}
