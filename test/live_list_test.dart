// ignore_for_file: unreachable_from_main

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:time/time.dart';
import 'package:v_flutter_core/src/utils/live_list/definitions.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

import 'utils/modular_stream.dart';

const liveListsDisposeDuration = Duration(milliseconds: 900);
const testTimeoutDuration = Duration(seconds: 1);

const a = _Model(id: 'a', name: 'A', foreignId: '1');
const aa = _Model(id: 'a', name: 'AA', foreignId: '2');
const aaa = _Model(id: 'a', name: 'AAA', foreignId: '2');
const aaaa = _Model(id: 'a', name: 'AAAA', foreignId: '3');
const b = _Model(id: 'b', name: 'B');
const bb = _Model(id: 'b', name: 'BB', foreignId: '2');
const bbb = _Model(id: 'b', name: 'BBB');
const c = _Model(id: 'c', name: 'C');
const cc = _Model(id: 'c', name: 'CC');
const ccc = _Model(id: 'c', name: 'CCC');

String _resolveId(_Model item) => item.id;

abstract class ItemFetcher {
  Future<_Model> fetchItem(String id);
  Future<List<_Model>> fetchItems(Iterable<String> ids);
}

class MockItemFetcher extends Mock implements ItemFetcher {}

LiveList<String, _Model> aLiveList({
  MockItemFetcher? mockFetcher,
  ItemListStreamBehavior itemListStreamBehavior = ItemListStreamBehavior.replace,
  String Function(_Model item) resolveId = _resolveId,
  Stream<List<_Model>>? itemListStream,
  ModularStream<_Model>? explicitItemCreatedStream,
  Stream<String>? itemCreatedTriggerStream,
  FutureOr<List<TriggerDefinition<_Model>>> Function(_Model item)? getTriggerDefinitions,
  List<(String? Function(_Model item), Map<String, ModularStream<_Model>>)>? explicitTriggerDefinitions,
  List<ListTriggerDefinition<_Model>> listDependencies = const [],
}) {
  assert(
    getTriggerDefinitions == null || explicitTriggerDefinitions == null,
    'Both getTriggerDefinitions and triggerDefinitionStream can not be defined at the same time',
  );
  final effectiveGetItemDependencyStream = getTriggerDefinitions ??
      ((explicitTriggerDefinitions?.isNotEmpty ?? false)
          ? (_Model item) {
              return explicitTriggerDefinitions!
                  .map(
                    (e) => TriggerDefinition<_Model>(
                      (_Model model) => e.$1(model),
                      (String id) {
                        final stream = e.$2[id];
                        if (stream == null) {
                          print('⚠️ Some dependency key of resolved to $id, but there is not stream defined for it');
                          return const Stream.empty();
                        }
                        stream.doBeforeData = (data) {
                          debugPrint('SETUP mockFetcher `fetchItem(${data.id})` to $data');
                          if (mockFetcher == null) {
                            throw 'You must define mockFetcher';
                          } else {
                            when(() => mockFetcher.fetchItem(data.id)).thenAnswer((_) async => data);
                          }
                        };
                        return stream.stream;
                      },
                    ),
                  )
                  .toList();
            }
          : null);

  explicitItemCreatedStream ??= ModularStream<_Model>([]);
  explicitItemCreatedStream.doBeforeData = (data) {
    debugPrint('SETUP mockFetcher `fetchItem(${data.id})` to $data');
    if (mockFetcher == null) {
      throw 'You must define mockFetcher';
    } else {
      when(() => mockFetcher.fetchItem(data.id)).thenAnswer((_) async => data);
    }
  };
  final effectiveItemCreatedTriggerStream = itemCreatedTriggerStream ?? explicitItemCreatedStream.stream.map(resolveId);

  final liveList = LiveList<String, _Model>(
    itemListStream: itemListStream ?? const Stream.empty(),
    resolveId: resolveId,
    fetchItem: (String id) {
      return mockFetcher!.fetchItem(id);
    },
    fetchItems: (Iterable<String> ids) {
      return mockFetcher!.fetchItems(ids);
    }.when(mockFetcher != null),
    itemCreatedTriggerStream: effectiveItemCreatedTriggerStream,
    getTriggerDefinitions: effectiveGetItemDependencyStream,
    listTriggers: listDependencies,
    itemListStreamBehavior: itemListStreamBehavior,
  );

  liveListsDisposeDuration.afterPassed(liveList.dispose);

  addTearDown(liveList.dispose);
  return liveList;
}

void main() {
  group(
    'Test timeouts after 1s',
    timeout: const Timeout(testTimeoutDuration),
    () {
      setUpAll(() {
        registerFallbackValue(const _Model(id: '1', name: '1'));
      });

      late MockItemFetcher mockFetcher;
      setUp(() {
        mockFetcher = MockItemFetcher();
      });
      tearDown(() {
        reset(mockFetcher);
      });

      group('group', () {
        group('subscription handling', () {
          group('when LiveList gets disposed', () {
            test('itemListStream subscription is disposed', () {
              final itemListStream = aModularStream<List<_Model>>([
                [a],
              ]);

              final liveList = aLiveList(itemListStream: itemListStream.stream);
              liveList.dispose();

              expect(itemListStream.subscriptionCount, 1);
              expect(itemListStream.cancelCount, 1);
            });
            test('itemCreatedTriggerStream subscription is disposed', () {
              final itemCreatedTriggerStream = aModularStream<String>([
                'a',
              ]);

              final liveList = aLiveList(itemCreatedTriggerStream: itemCreatedTriggerStream.stream);
              liveList.dispose();

              expect(itemCreatedTriggerStream.subscriptionCount, 1);
              expect(itemCreatedTriggerStream.cancelCount, 1);
            });
            test('TriggerDefinition stream subscription is disposed', () async {
              final triggerStream = aModularStream<_Model>([
                aa,
              ]);

              final liveList = aLiveList(
                mockFetcher: mockFetcher,
                itemListStream: aStream([
                  [a],
                ]),
                explicitTriggerDefinitions: [
                  (
                    (item) => item.foreignId,
                    {
                      '1': triggerStream,
                    },
                  ),
                ],
              );
              await Future<void>.delayed(1.milliseconds);
              liveList.dispose();

              expect(triggerStream.subscriptionCount, 1);
              expect(triggerStream.cancelCount, 1);
            });
            test('listDependencies subscription is disposed', () {
              final listDependencyStream = aModularStream<List<_Model>>([
                [aa],
              ]);

              final liveList = aLiveList(
                mockFetcher: mockFetcher,
                listDependencies: [
                  ListTriggerDefinition(
                    appliesTo: (item) => item.foreignId == '2',
                    stream: listDependencyStream.stream,
                  ),
                ],
              );
              liveList.dispose();

              expect(listDependencyStream.subscriptionCount, 1);
              expect(listDependencyStream.cancelCount, 1);
            });
          });

          group('TriggerDefinition', () {
            test('TriggerDefinition stream is only listened to once', () async {
              final triggerStream = aModularStream<_Model>([]);

              aLiveList(
                mockFetcher: mockFetcher,
                itemListStream: aStream([
                  [aa],
                  [aaa],
                  [aa],
                  [aaa],
                  [aa],
                  [aaa],
                  [aa],
                  [aaa],
                ]),
                explicitTriggerDefinitions: [
                  (
                    (item) => item.foreignId,
                    {
                      '2': triggerStream,
                    },
                  ),
                ],
              );
              await Future<void>.delayed(1.milliseconds);

              expect(triggerStream.subscriptionCount, 1);
              expect(triggerStream.cancelCount, 1);
            });
            test(
                'TriggerDefinition stream subscription is disposed when a new item is fetched that makes it irrelevant',
                () async {
              final triggerStream = aModularStream<_Model>([
                aaa,
              ]);

              aLiveList(
                mockFetcher: mockFetcher,
                itemListStream: aStream([
                  [a],
                ]),
                explicitTriggerDefinitions: [
                  (
                    (item) => item.foreignId,
                    {
                      '1': triggerStream,
                    },
                  ),
                ],
              );
              await Future<void>.delayed(1.milliseconds);

              expect(triggerStream.subscriptionCount, 1);
              expect(triggerStream.cancelCount, 1);
            });
            test('TriggerDefinition stream subscription is disposed when item is removed', () async {
              final triggerStream = aModularStream<_Model>([
                100.milliseconds,
                aaa,
              ]);

              final liveList = aLiveList(
                mockFetcher: mockFetcher,
                itemListStream: aStream([
                  [a],
                ]),
                explicitTriggerDefinitions: [
                  (
                    (item) => item.foreignId,
                    {
                      '1': triggerStream,
                      '2': ModularStream<_Model>([]),
                    },
                  ),
                ],
              );

              await expectLater(liveList.stream, emits([a]));
              liveList.removeItem(a.id);
              await expectLater(liveList.stream, emits([]));
              expect(
                liveList.stream,
                neverEmits([
                  [aaa],
                ]),
              );

              expect(triggerStream.subscriptionCount, 1);
              expect(triggerStream.emissionCount, 0);
              expect(triggerStream.cancelCount, 1);
            });
            test('TriggerDefinition stream subscription is not listened to once when other stream becomes active',
                () async {
              final aIdTriggerStream = aModularStream<_Model>([
                50.milliseconds,
                aaa,
                50.milliseconds,
                a,
              ]);
              final foreignId2TriggerStream = aModularStream<_Model>([
                75.milliseconds,
                aaaa,
              ]);

              final liveList = aLiveList(
                mockFetcher: mockFetcher,
                itemListStream: aStream([
                  [aa],
                ]),
                explicitTriggerDefinitions: [
                  (
                    (item) => item.foreignId,
                    {
                      '1': ModularStream<_Model>([]),
                      '2': foreignId2TriggerStream,
                      '3': ModularStream<_Model>([]),
                    },
                  ),
                  (
                    (item) => item.id,
                    {
                      'a': aIdTriggerStream,
                    },
                  ),
                ],
              );

              await expectLater(
                liveList.stream,
                emitsInOrder([
                  [aa],
                  [aaa],
                  [aaaa],
                  [a],
                ]),
              );

              expect(aIdTriggerStream.subscriptionCount, 1);
              expect(aIdTriggerStream.cancelCount, 1);
            });
          });
          group('listDependencies', () {
            test('ListTriggerDefinition stream is only listened to once', () async {
              when(() => mockFetcher.fetchItems(['a'])).thenAnswer((_) async => [aaa]);
              final listDependencyStream = aTriggerStream([
                25.milliseconds,
                25.milliseconds,
                25.milliseconds,
                25.milliseconds,
              ]);

              final liveList = aLiveList(
                mockFetcher: mockFetcher,
                itemListStream: aStream([
                  [aa],
                ]),
                listDependencies: [
                  ListTriggerDefinition(
                    appliesTo: (item) => item.foreignId == '2',
                    stream: listDependencyStream.stream,
                  ),
                ],
              );

              expect(
                liveList.stream,
                emitsInOrder([
                  [aa],
                  [aaa],
                  [aaa],
                  [aaa],
                  [aaa],
                ]),
              );
              expect(listDependencyStream.subscriptionCount, 1);
            });
          });
        });

        group('itemListStream', () {
          group('behavior: replace', () {
            test('events are emitted, replacing existing items', () {
              final liveList = aLiveList(
                // ignore: avoid_redundant_argument_values
                itemListStreamBehavior: ItemListStreamBehavior.replace,
                mockFetcher: mockFetcher,
                itemListStream: aStream([
                  [a],
                  [a, b],
                  [b],
                ]),
              );

              expect(
                liveList.stream,
                emitsInOrder([
                  [a],
                  [a, b],
                  [b],
                ]),
              );
            });
          });
          group('behavior: add', () {
            test('events are emitted, adding to existing items', () {
              final liveList = aLiveList(
                // ignore: avoid_redundant_argument_values
                itemListStreamBehavior: ItemListStreamBehavior.add,
                mockFetcher: mockFetcher,
                itemListStream: aStream([
                  [a],
                  [b],
                  [bb],
                ]),
              );

              expect(
                liveList.stream,
                emitsInOrder([
                  [a],
                  [a, b],
                  [a, bb],
                ]),
              );
            });
          });
        });

        group('itemCreatedTriggerStream', () {
          test('items are added to the list', () async {
            final liveList = aLiveList(
              mockFetcher: mockFetcher,
              explicitItemCreatedStream: aModularStream([a, bb, ccc]),
            );

            expect(
              liveList.stream,
              emitsInOrder([
                [a],
                [a, bb],
                [a, bb, ccc],
              ]),
            );
          });
        });

        group('TriggerDefinition', () {
          test('singular trigger stream items are added to the list', () {
            final liveList = aLiveList(
              mockFetcher: mockFetcher,
              itemListStream: aStream([
                [aa],
              ]),
              explicitTriggerDefinitions: [
                (
                  (item) => item.foreignId,
                  {
                    '2': ModularStream<_Model>([
                      10.milliseconds,
                      aaa,
                      10.milliseconds,
                      aa,
                      10.milliseconds,
                      aaa,
                      10.milliseconds,
                      aa,
                    ]),
                  },
                ),
              ],
            );

            expect(
              liveList.stream,
              emitsInOrder([
                [aa],
                [aaa],
                [aa],
                [aaa],
                [aa],
              ]),
            );
          });
          test('multiple trigger streams update the list simultaneously', () {
            final liveList = aLiveList(
              mockFetcher: mockFetcher,
              itemListStream: aStream([
                [aa],
              ]),
              explicitTriggerDefinitions: [
                (
                  (item) => item.id,
                  {
                    'a': ModularStream<_Model>([
                      30.milliseconds,
                      aaa,
                      30.milliseconds,
                      aaa,
                    ]),
                  },
                ),
                (
                  (item) => item.foreignId,
                  {
                    '2': ModularStream<_Model>([
                      50.milliseconds,
                      aa,
                      50.milliseconds,
                      aa,
                    ]),
                  },
                ),
              ],
            );

            expect(
              liveList.stream,
              emitsInOrder([
                [aa],
                [aaa],
                [aa],
                [aaa],
                [aa],
              ]),
            );
          });
          test('one trigger stream can rule out other, by making the requirement not met', () {
            final liveList = aLiveList(
              mockFetcher: mockFetcher,
              itemListStream: aStream([
                [aa],
              ]),
              explicitTriggerDefinitions: [
                (
                  (item) => item.id,
                  {
                    'a': ModularStream<_Model>([
                      50.milliseconds,
                      a, // foreignId is not '2' but '1'
                    ]),
                  },
                ),
                (
                  (item) => item.foreignId,
                  {
                    '2': ModularStream<_Model>([
                      30.milliseconds,
                      aaa,
                      50.milliseconds,
                      aaaa,
                    ]),
                  },
                ),
              ],
            );

            expect(
              liveList.stream,
              emitsInOrder([
                [aa],
                [aaa],
                [a],
              ]),
            );
            expect(
              liveList.stream,
              neverEmits([
                [aaaa],
              ]),
            );
          });
        });
        group('ListTriggerDefinition', () {
          test('Fetches items that apply the defintin', () async {
            when(() => mockFetcher.fetchItems(['a', 'b'])).thenAnswer((_) async => [a, bb]);
            when(() => mockFetcher.fetchItems(['b'])).thenAnswer((_) async => [b]);

            final liveList = aLiveList(
              mockFetcher: mockFetcher,
              itemListStream: aStream([
                [aa, bb],
              ]),
              listDependencies: [
                ListTriggerDefinition(
                  appliesTo: (item) => item.foreignId == '2',
                  stream: aTriggerStream([
                    10.milliseconds,
                    10.milliseconds,
                    10.milliseconds,
                    10.milliseconds,
                    10.milliseconds,
                  ]).stream,
                ),
              ],
            );

            await expectLater(
              liveList.stream,
              emitsInOrder([
                [aa, bb],
                [a, bb],
                [a, b],
              ]),
            );
            verify(() => mockFetcher.fetchItems(['a', 'b'])).called(1);
            verify(() => mockFetcher.fetchItems(['b'])).called(1);
            verifyNoMoreInteractions(mockFetcher);
          });
        });
      });

      group('deferredItemTrigger', () {
        group('0 trigger while deferring', () {
          test('deferred item is added if succeeds, no fresh item is fetched', () async {
            final liveList = aLiveList(
              mockFetcher: mockFetcher,
              getTriggerDefinitions: (item) {
                return [
                  TriggerDefinition(
                    (_model) => _model.id,
                    (id) => const Stream.empty(),
                  ),
                ];
              },
            );
            liveList.upsertItem(a);

            final completer = liveList.deferItemTrigger('a');
            expect(completer.isRight(), isTrue);
            await completer.fold(
              (_) => throw 'Expected a completer',
              (completer) async {
                await Future.delayed(50.milliseconds);
                expect(liveList.items, equals([a]));
                completer.complete(aaa);
                await completer.future;
                await expectLater(
                  liveList.stream,
                  emitsInOrder([
                    [aaa],
                  ]),
                );
                verifyZeroInteractions(mockFetcher);
              },
            );
          });
          test('no item is added if deferred item fails', () async {
            final liveList = aLiveList(
              mockFetcher: mockFetcher,
              getTriggerDefinitions: (item) {
                return [
                  TriggerDefinition(
                    (_model) => _model.id,
                    (id) => const Stream.empty(),
                  ),
                ];
              },
            );
            liveList.upsertItem(a);

            final completer = liveList.deferItemTrigger('a');
            expect(completer.isRight(), isTrue);
            await completer.fold(
              (_) => throw 'Expected a completer',
              (completer) async {
                expect(liveList.items, equals([a]));
                await Future.delayed(50.milliseconds);
                completer.completeError(Exception('failed'));
                await completer.futureIgnoreErrors;
                verifyZeroInteractions(mockFetcher);
                expect(liveList.items, equals([a]));
              },
            );
          });
        });

        group('exactly 1 trigger while deferring', () {
          test('deferred item is added if succeeds, no fresh item is fetched', () async {
            final liveList = aLiveList(
              mockFetcher: mockFetcher,
              explicitTriggerDefinitions: [
                (
                  (item) => item.foreignId,
                  {
                    '1': ModularStream<_Model>([
                      50.milliseconds,
                      aa,
                    ]),
                  },
                ),
              ],
            );
            liveList.upsertItem(a);

            final completer = liveList.deferItemTrigger('a');
            expect(completer.isRight(), isTrue);
            completer.fold(
              (_) => throw 'Expected a completer',
              (completer) async {
                await Future.delayed(100.milliseconds);
                completer.complete(aaa);
                await completer.future;
                verifyZeroInteractions(mockFetcher);
              },
            );

            await expectLater(
              liveList.stream,
              emitsInOrder([
                [a],
                [aaa],
              ]),
            );
          });
          test('fresh item is fetched if deferred item fails', () async {
            final liveList = aLiveList(
              mockFetcher: mockFetcher,
              explicitTriggerDefinitions: [
                (
                  (item) => item.foreignId,
                  {
                    '1': ModularStream<_Model>([
                      50.milliseconds,
                      aa,
                    ]),
                  },
                ),
              ],
            );
            liveList.upsertItem(a);

            final completer = liveList.deferItemTrigger('a');
            expect(completer.isRight(), isTrue);
            completer.fold(
              (_) => throw 'Expected a completer',
              (completer) async {
                await Future.delayed(100.milliseconds);
                when(() => mockFetcher.fetchItem('a')).thenAnswer((_) async => aaaa);
                completer.completeError(Exception('failed'));
                await completer.futureIgnoreErrors;
                verify(() => mockFetcher.fetchItem('a')).called(1);
              },
            );

            await expectLater(
              liveList.stream,
              emitsInOrder([
                [a],
                [aaaa],
              ]),
            );
          });
        });

        group('more than 1 trigger while deferring', () {
          test('deferred item is ignored, fresh item is fetched', () async {
            final liveList = aLiveList(
              mockFetcher: mockFetcher,
              explicitTriggerDefinitions: [
                (
                  (item) => item.foreignId,
                  {
                    '1': ModularStream<_Model>([
                      // 30.milliseconds,
                      // aa,
                      // 30.milliseconds,
                      // aa,
                      20.milliseconds,
                      aa,
                      20.milliseconds,
                      aa,
                      20.milliseconds,
                      aa,
                      20.milliseconds,
                      aa,
                    ]),
                  },
                ),
              ],
            );
            liveList.upsertItem(a);

            final completer = liveList.deferItemTrigger('a');
            expect(completer.isRight(), isTrue);
            completer.fold(
              (_) => throw 'Expected a completer',
              (completer) async {
                await Future.delayed(100.milliseconds);
                when(() => mockFetcher.fetchItem('a')).thenAnswer((_) async => aaaa);
                completer.complete(aaa);
                await completer.future;
              },
            );

            expect(
              liveList.stream,
              neverEmits([
                [aa],
                [aaa],
              ]),
            );
            await expectLater(
              liveList.stream,
              emitsInOrder([
                [a],
                [aaaa],
              ]),
            );
          });

          test('when fresh item fails to fetch, deferred item is added nevertheless', () async {
            final liveList = aLiveList(
              mockFetcher: mockFetcher,
              explicitTriggerDefinitions: [
                (
                  (item) => item.foreignId,
                  {
                    '1': ModularStream<_Model>([
                      30.milliseconds,
                      aa,
                      30.milliseconds,
                      aa,
                    ]),
                  },
                ),
              ],
            );
            liveList.upsertItem(a);

            final completer = liveList.deferItemTrigger('a');
            expect(completer.isRight(), isTrue);
            completer.fold(
              (_) => throw 'Expected a completer',
              (completer) async {
                await Future.delayed(100.milliseconds);
                when(() => mockFetcher.fetchItem('a')).thenThrow(Exception('failed'));
                completer.complete(aaa);
                await completer.future;
              },
            );

            expect(
              liveList.stream,
              neverEmits([
                [aa],
                [aaaa],
              ]),
            );
            await expectLater(
              liveList.stream,
              emitsInOrder([
                [a],
                [aaa],
              ]),
            );
          });
        });
      });
    },
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

ModularStream<Duration> aTriggerStream(List<Duration> items) => ModularStream<Duration>(items);
ModularStream<T> aModularStream<T>(List<Object> items) => ModularStream<T>(items);
Stream<T> aStream<T>(List<Object> items) => aModularStream<T>(items).stream;

extension on Duration {
  Future<void> afterPassed(FutureOr<void> Function() action) => Future<void>.delayed(this).then((_) => action());
}

extension on Completer<void> {
  Future<void> get futureIgnoreErrors async {
    try {
      await future;
    } catch (e) {
      // ignore
    }
  }
}
