import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';
import 'package:v_flutter_core/src/utils/mutation_provider.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

import 'live_list_test.dart';
import 'provider_container.dart';
import 'utils/comment.dart';

part 'mutation_provider_test.g.dart';

void main() {
  late ProviderContainer c;

  // late CommentList commentList;

  setUp(() {
    // commentList = CommentListMock();
    // when(() => commentList.build()).thenAnswer((_) => Stream.value([comment1, comment2]));

    c = createContainer(
        // overrides: [commentListPod.overrideWith(() => commentList)],
        );
  });

  tearDown(() => c.dispose());

  group(
    'timeout',
    () {
      group('riverpod experiments', () {
        test('1', () {
          expect(
            c.testRead(commentListPod),
            equals(const AsyncLoading<List<Comment>>()),
          );
        });

        test('2', () {
          expectLater(
            c.testRead(commentListPod.future),
            completion(equals([comment1, comment2])),
          );
        });
      });

      group('MutationProvider', () {
        test('Emits AsyncLoading initially', () {
          expect(
            c.testRead(mutableCommentPod(id: comment1.id)),
            equals(const AsyncLoading<MPS<CommentMutation, Comment>>()),
          );
        });
        test('Emits MPS with null mutationType and comment resolved from commentListPod', () {
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
            final stream = c.streamOfAsyncData(mutableCommentPod(id: comment1.id));

            await c.testRead(mutableCommentPod(id: comment1.id).future);
            await c.testRead(mutableCommentPod(id: comment1.id).notifier).like();

            expect(
              stream,
              emitsInOrder([
                equals(MPS<CommentMutation, Comment>(mutationType: null, data: comment1)),
                equals(MPS<CommentMutation, Comment>(mutationType: CommentMutation.like, data: comment1)),
                equals(MPS<CommentMutation, Comment>(mutationType: null, data: comment1.copyWith(likes: 1))),
              ]),
            );
          });
          test('Emits mutation flow MPS values when item is updated in LiveList', () async {
            final stream = c.streamOfAsyncData(mutableCommentPod(id: comment1.id));

            await c.testRead(mutableCommentPod(id: comment1.id).future);
            c.testRead(mutableCommentPod(id: comment1.id).notifier).like();
            c.testRead(commentListPod.notifier).change([comment1.copyWith(likes: 2), comment2]);

            expect(
              stream,
              emitsInOrder([
                equals(MPS<CommentMutation, Comment>(mutationType: null, data: comment1)),
                equals(MPS<CommentMutation, Comment>(mutationType: CommentMutation.like, data: comment1)),
                equals(
                  MPS<CommentMutation, Comment>(mutationType: CommentMutation.like, data: comment1.copyWith(likes: 2)),
                ),
                equals(MPS<CommentMutation, Comment>(mutationType: null, data: comment1.copyWith(likes: 1))),
              ]),
            );
          });
        });
      });
    },
    timeout: const Timeout(testTimeoutDuration),
  );
}


@riverpod
class CommentList extends _$CommentList {
  @override
  Stream<List<Comment>> build() => Stream.value([comment1, comment2]).delay(const Duration(milliseconds: 100));

  void change(List<Comment> comments) {
    state = AsyncData(comments);
  }
}

class CommentListMock extends _$CommentList with Mock implements CommentList {}

enum CommentMutation { edit, like }

@riverpod
class MutableComment extends _$MutableComment with MutationProvider<CommentMutation, Comment> {
  @override
  Stream<MPS<CommentMutation, Comment>> build({required String id}) => selectItemStream;

  @override
  Future<Completer<Comment>>? get completer => null;

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
