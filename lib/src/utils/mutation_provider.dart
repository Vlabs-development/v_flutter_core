import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

abstract class MutationFailure {
  AsyncError<T> asAsyncError<T>() => AsyncError<T>('MutationFailure', StackTrace.current);
}

class MutationWhileLoading implements MutationFailure {
  @override
  AsyncError<T> asAsyncError<T>() => AsyncError<T>('MutationWhileLoading', StackTrace.current);
}

class MutationWithoutInitialData implements MutationFailure {
  @override
  AsyncError<T> asAsyncError<T>() => AsyncError<T>('MutationWithoutInitialData', StackTrace.current);
}

class MutationFailed implements MutationFailure {
  MutationFailed(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;

  @override
  AsyncError<T> asAsyncError<T>() => AsyncError<T>(error, stackTrace);
}

class MPS<MT, T> {
  MPS({required this.mutationType, required this.data});

  final MT? mutationType;
  final T data;

  @override
  String toString() => 'MPS{mutationType: $mutationType, data: $data}';
}

extension MPSAsyncValueExtension<MT, T> on AsyncValue<MPS<MT, T>> {
  bool isInProgress(MT mutationType) {
    return maybeWhen(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      loading: () => valueOrNull?.mutationType == mutationType,
      orElse: () => false,
    );
  }
}

// ignore: invalid_use_of_internal_member
mixin MutationProvider<MT, T> on BuildlessAutoDisposeStreamNotifier<MPS<MT, T>> {
  void onMutated(T previous, T next) {}

  Completer<T>? get completer;

  ProviderListenable<Future<T?>> get selectItem;

  Stream<MPS<MT, T>> get selectItemStream => ref
      .streamOf(selectItem, fireImmediately: true)
      .asyncMap((event) => event)
      .whereType<T>()
      .map((item) => asMutationState(item));

  MPS<MT, T> asMutationState(T item) => state.map<MPS<MT, T>>(
        data: (data) => MPS(mutationType: null, data: item),
        loading: (loading) => MPS(mutationType: loading.valueOrNull?.mutationType, data: item),
        error: (error) => MPS(mutationType: null, data: item),
      );

  Future<Either<MutationFailure, T>> mutate({
    required MT mutationType,
    required Future<T> Function(T) mutate,
    Completer<T>? completer,
    bool skipError = true,
  }) async {
    final currentData = state.valueOrNull?.data;
    if (state.isLoading) {
      final currentMutation = state.actualValueOrNull?.mutationType;
      debugPrint('MUTATION $mutationType FAILED BECAUSE CURRENTLY $currentMutation IS IN PROGRESS');
      return Left(MutationWhileLoading());
    }

    if (currentData == null) {
      return Left(MutationWithoutInitialData());
    }

    state = AsyncLoading<MPS<MT, T>>().copyWithPrevious(
      AsyncData(
        MPS(mutationType: mutationType, data: currentData),
      ),
    );

    final taskEither = TaskEither<MutationFailure, T>.tryCatch(
      () => mutate(currentData),
      (error, stackTrace) => MutationFailed(error, stackTrace),
    );
    final _completer = completer ?? this.completer;

    final mutateResult = await taskEither.run();

    return mutateResult.fold(
      (mutationFailure) {
        if (skipError) {
          if (_completer == null) {
            state = AsyncData(MPS(mutationType: null, data: currentData));
          } else {
            _completer.completeError(mutationFailure);
          }
          return Right(currentData);
        } else {
          if (_completer == null) {
            state = mutationFailure
                .asAsyncError<MPS<MT, T>>()
                .copyWithPrevious(AsyncData(MPS(mutationType: mutationType, data: currentData)));
          } else {
            _completer.completeError(mutationFailure);
          }

          return Left(mutationFailure);
        }
      },
      (mutatedData) {
        if (_completer == null) {
          state = AsyncData(MPS(mutationType: null, data: mutatedData));
        } else {
          _completer.complete(mutatedData);
        }
        onMutated(currentData, mutatedData);
        return Right(mutatedData);
      },
    );
  }

  Future<Either<MutationFailure, K>> mutateTransitive<K>({
    required MT mutationType,
    required Future<K> Function() mutate,
  }) async {
    final currentData = state.valueOrNull?.data;
    if (state.isLoading) {
      return Left(MutationWhileLoading());
    }

    if (currentData == null) {
      return Left(MutationWithoutInitialData());
    }

    state = AsyncLoading<MPS<MT, T>>().copyWithPrevious(AsyncData(MPS(mutationType: mutationType, data: currentData)));

    final taskEither = TaskEither<MutationFailure, K>.tryCatch(
      () => mutate(),
      (error, stackTrace) => MutationFailed(error, stackTrace),
    );
    final mutateResult = await taskEither.run();

    return mutateResult.fold(
      (mutationFailure) {
        state = mutationFailure
            .asAsyncError<MPS<MT, T>>()
            .copyWithPrevious(AsyncData(MPS(mutationType: mutationType, data: currentData)));

        return Left(mutationFailure);
      },
      (mutatedData) {
        // provider is in some state, will [hopefully] get updated by eventual fire of updated item.
        return Right(mutatedData);
      },
    );
  }
}
