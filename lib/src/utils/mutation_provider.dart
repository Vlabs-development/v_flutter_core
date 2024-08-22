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

  HandshakeCompleter<T>? get completer;

  ProviderListenable<Future<T?>> get selectItem;

  Stream<MPS<MT, T>> get selectItemStream => ref
      .streamOf(selectItem, fireImmediately: true)
      .asyncMap((event) => event)
      .whereType<T>()
      .map((item) => asMutationState(item))
      .doOnData((event) => timedDP(
          '💨💨 Syncronized an item from LiveList ${event.mutationType == null ? '' : "while mutation: ${event.mutationType} is in progress"}'));

  MPS<MT, T> asMutationState(T item) => state.map<MPS<MT, T>>(
        data: (data) => MPS(mutationType: data.valueOrNull?.mutationType, data: item),
        loading: (loading) => MPS(mutationType: loading.valueOrNull?.mutationType, data: item),
        error: (error) => MPS(mutationType: error.valueOrNull?.mutationType, data: item),
      );

  Future<Either<MutationFailure, T>> mutate({
    required MT mutationType,
    required Future<T> Function(T) mutate,
    HandshakeCompleter<T>? completer,
    bool skipError = true,
  }) async {
    final currentData = state.valueOrNull?.data;
    if (state.isLoading) {
      final currentMutation = state.actualValueOrNull?.mutationType;
      timedDP('🟪🟥 MUTATION $mutationType FAILED BECAUSE CURRENTLY $currentMutation IS IN PROGRESS');
      return Left(MutationWhileLoading());
    }

    if (currentData == null) {
      timedDP('🟪🟥 MUTATION $mutationType FAILED BECAUSE CURRENT DATA IS NULL');
      return Left(MutationWithoutInitialData());
    }

    state = AsyncLoading<MPS<MT, T>>().copyWithPrevious(
      AsyncData(
        MPS(mutationType: mutationType, data: currentData),
      ),
    );

    final taskEither = TaskEither<MutationFailure, T>.tryCatch(
      () {
        debugPrint('_____ mutating $mutationType');
        return mutate(currentData);
      },
      (error, stackTrace) => MutationFailed(error, stackTrace),
    );
    final _completer = completer ?? this.completer;

    timedDP('🟪🟪 MUTATION $mutationType - ${_completer?.hashCode ?? 'no completer'} ${_completer?.isCompleted ?? ''}');
    final mutateResult = await taskEither.run();

    return mutateResult.fold(
      (mutationFailure) async {
        timedDP('🟪🟥 MUTATION $mutationType ERROR: $mutationFailure');
        if (skipError) {
          if (_completer != null) {
            _completer.completeError(mutationFailure);
          }
          state = AsyncData(MPS(mutationType: null, data: currentData));
          return Right(currentData);
        } else {
          if (_completer != null) {
            _completer.completeError(mutationFailure);
          }

          state = mutationFailure
              .asAsyncError<MPS<MT, T>>()
              .copyWithPrevious(AsyncData(MPS(mutationType: mutationType, data: currentData)));
          return Left(mutationFailure);
        }
      },
      (mutatedData) async {
        if (_completer != null) {
          await _completer.completeAwaitingHandshake(mutatedData);
        }
        state = AsyncData(MPS(mutationType: null, data: mutatedData));
        onMutated(currentData, mutatedData);
        timedDP('🟪🟩 MUTATION $mutationType');
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

(String, Duration) _formattedCurrentTime({DateTime? since}) {
  final now = DateTime.now();
  final elapsed = now.difference(since ?? now);
  final hours = now.hour.toString().padLeft(2, '0');
  final minutes = now.minute.toString().padLeft(2, '0');
  final seconds = now.second.toString().padLeft(2, '0');
  final milliseconds = now.millisecond.toString().padLeft(3, '0');
  final timestamp = '$hours:$minutes:$seconds.$milliseconds';

  if (elapsed > Duration.zero) {
    return (timestamp, elapsed);
  }

  return (timestamp, Duration.zero);
}

void timedDP(String value, {DateTime? since}) {
  final timePart = _formattedCurrentTime(since: since);
  final durationPart = timePart.$2 == Duration.zero ? '' : '${timePart.$2.inMilliseconds}ms';
  final paddedDurationPart = durationPart.padLeft(6);
  debugPrint('${timePart.$1} $paddedDurationPart $value');
}
