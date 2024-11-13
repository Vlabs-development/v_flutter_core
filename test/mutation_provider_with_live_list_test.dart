// ignore_for_file: unreachable_from_main

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test/test.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

import 'live_list_test.dart';
import 'provider_container.dart';
import 'utils/comment.dart';

part 'mutation_provider_with_live_list_test.g.dart';

void main() {
  late ProviderContainer c;

  late StreamController<List<Comment>> apiCommentListController;

  setUp(() {
    apiCommentListController = StreamController<List<Comment>>();

    c = createContainer(
      overrides: [
        apiCommentListPod.overrideWith((ref) => apiCommentListController.stream),
      ],
    );
  });

  tearDown(() {
    c.dispose();
    apiCommentListController.close();
  });

  group(
    'timeout',
    () {
      group('MutationProvider with LiveList', () {
        test('Emits AsyncLoading initially', () {
          expect(
            c.testRead(mutableCommentPod(id: comment1.id)),
            equals(const AsyncLoading<MPS<CommentMutation, Comment>>()),
          );
        });
        test('Emits MPS with null mutationType and comment resolved from commentListPod', () {
          apiCommentListController.add([comment1]);

          expectLater(
            c.testRead(mutableCommentPod(id: comment1.id).future),
            completion(equals(MPS<CommentMutation, Comment>(mutationType: null, data: comment1))),
          );
        });

        group('Mutating', () {
          test('Returns Left(MutationWhileLoading) when mutation is called while data is yet to be load', () async {
            expectLater(
              c.testRead(mutableCommentPod(id: comment1.id).notifier).like(),
              completion(equals(Left<MutationFailure, Comment>(MutationWhileLoading()))),
            );
          });
          test('Emits mutation flow MPS values', () async {
            apiCommentListController.add([comment1]);
            final stream = c.streamOfAsyncValue(mutableCommentPod(id: comment1.id));

            await c.testRead(mutableCommentPod(id: comment1.id).future);
            c.testRead(mutableCommentPod(id: comment1.id).notifier).like();

            // expect(
            //   stream,
            //   emitsInOrder([
            //     equals(_asyncData(MPS(mutationType: null, data: comment1))),
            //   ]),
            // );
            expect(
              stream,
              emitsInOrder([
                equals(_asyncData(MPS(mutationType: null, data: comment1))),
                equals(_asyncLoading(MPS(mutationType: CommentMutation.like, data: comment1))),
                equals(_asyncData(MPS(mutationType: null, data: comment1.copyWith(likes: 1)))),
              ]),
            );
          });
          test('when item is updated in source while mutation is in progress', () async {
            apiCommentListController.add([comment1]);
            final stream = c.streamOfAsyncValue(mutableCommentPod(id: comment1.id));

            await c.testRead(mutableCommentPod(id: comment1.id).future);
            c.testRead(mutableCommentPod(id: comment1.id).notifier).like();
            apiCommentListController.add([comment1.copyWith(content: 'updated')]);

            expect(
              stream,
              emitsInOrder([
                equals(_asyncData(MPS(mutationType: null, data: comment1))),
                equals(_asyncLoading(MPS(mutationType: CommentMutation.like, data: comment1))),
                equals(_asyncData(MPS(mutationType: CommentMutation.like, data: comment1.copyWith(content: 'updated')))),
                equals(_asyncData(MPS(mutationType: null, data: comment1.copyWith(likes: 1)))),
              ]),
            );
          });
        });
      });
    },
    timeout: const Timeout(testTimeoutDuration),
  );
}

AsyncValue<MPS<CommentMutation, Comment>> _asyncLoading(MPS<CommentMutation, Comment> data) =>
    const AsyncLoading<MPS<CommentMutation, Comment>>().copyWithPrevious(AsyncData(data));
    
AsyncValue<MPS<CommentMutation, Comment>> _asyncData(MPS<CommentMutation, Comment> data) => AsyncData(data);

@riverpod
Stream<List<Comment>> apiCommentList(Ref ref) => throw UnimplementedError();

@riverpod
LiveList<String, Comment> commentLiveList(Ref ref) {
  final liveList = LiveList<String, Comment>(
    resolveId: (item) => item.id,
    itemListStream: ref.streamOfAsyncData(
      apiCommentListPod,
      fireImmediately: true,
      skipLoadingOnRefresh: false,
    ),
    // getItemTriggerStream: (id) => ref.read(P.commentService).onCommentUpdatedId(id: id),
    // fetchItem: (id) => ref.read(P.commentService).getComment(id: id),
    // itemCreatedStream: ref.streamOfAsyncData(_commentInNewMessagesProvider),
    // listenPredicate: (a) => !a.isCanceled && !a.isDeclined && !a.isExpired && !a.isAbandoned,
  );

  ref.onDispose(() => liveList.dispose());
  return liveList;
}

@riverpod
Stream<List<Comment>> commentList(Ref ref) => ref.watch(commentLiveListPod).stream;

enum CommentMutation { edit, like }

@riverpod
class MutableComment extends _$MutableComment with MutationProvider<CommentMutation, Comment> {
  @override
  Stream<MPS<CommentMutation, Comment>> build({required String id}) {
    ref.debugPrintState(extractValue: (a) => a.toString(), name: '__ MutableComment');
    
    return selectItemStream;
  }

  @override
  HandshakeCompleter<Comment>? get completer => ref.read(commentLiveListPod).deferItemTrigger(id);

  @override
  ProviderListenable<Future<Comment?>> get selectItem {
    return commentListPod.selectAsync((value) => value.firstWhereOrNull((a) => a.id == id));
  }

  Future<Either<MutationFailure, Comment>> like() => mutate(
        mutationType: CommentMutation.like,
        mutate: (c) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return c.copyWith(likes: c.likes + 1);
        },
      );

  Future<Either<MutationFailure, Comment>> edit({required String content}) => mutate(
        mutationType: CommentMutation.edit,
        mutate: (c) async => c.copyWith(content: content),
      );
}

extension AsyncValueRefX<T> on Ref<AsyncValue<T>> {
  void debugPrintState({
    required String Function(T) extractValue,
    required String name,
  }) {
    int listenerCount = 0;

    String nullableExtractValue(T? nullableValue) {
      if (nullableValue == null) {
        return 'null';
      } else {
        return extractValue(nullableValue);
      }
    }

    void printValue(AsyncValue<T>? asyncValue, {required String prefix, required String arrow}) {
      if (asyncValue == null) {
        print('$prefix　　 $name $arrow no value');
        return;
      }

      asyncValue.when(
        data: (data) => print('$prefix　🟢 $name $arrow ${extractValue(data)}'),
        error: (error, stackTrace) => print('$prefix　🔴 $name $arrow $error'),
        loading: () {
          if (asyncValue.isInitialLoading) {
            print('$prefix🔄🌱 $name $arrow initialLoading');
          }
          if (asyncValue.isRefreshing) {
            print('$prefix🔄🫥 $name $arrow ${nullableExtractValue(asyncValue.actualValueOrNull)}');
          }
          if (asyncValue.isReloading) {
            print('$prefix🔄🔗 $name $arrow ${nullableExtractValue(asyncValue.actualValueOrNull)}');
          }
        },
        skipLoadingOnRefresh: false,
        skipLoadingOnReload: false,
      );
    }

    void printPrevious(AsyncValue<T>? asyncValue) => printValue(asyncValue, prefix: '', arrow: '<-');
    void printNext(AsyncValue<T> asyncValue) => printValue(asyncValue, prefix: '', arrow: '->');

    listenSelf((previous, next) {
      printPrevious(previous);
      printNext(next);
    });
    print('LIFECYCLE 🌱 $name');
    onDispose(() => print('LIFECYCLE 🗑 $name ($listenerCount)'));
    onCancel(() => print('LIFECYCLE ❌ $name ($listenerCount)'));
    onResume(() => print('LIFECYCLE 🔊 $name ($listenerCount)'));
    onAddListener(() {
      listenerCount++;
      print('LIFECYCLE 🦻 $name ($listenerCount)');
    });
    onRemoveListener(() {
      listenerCount--;
      print('LIFECYCLE 🦻❌ $name ($listenerCount)');
    });
  }
}