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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MutationWhileLoading;
  }

  @override
  int get hashCode => 'MutationWhileLoading'.hashCode;
}

class MutationWithoutInitialData implements MutationFailure {
  @override
  AsyncError<T> asAsyncError<T>() => AsyncError<T>('MutationWithoutInitialData', StackTrace.current);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MutationWhileLoading;
  }

  @override
  int get hashCode => 'MutationWithoutInitialData'.hashCode;
}

class MutationFailed implements MutationFailure {
  MutationFailed(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;

  @override
  AsyncError<T> asAsyncError<T>() => AsyncError<T>(error, stackTrace);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MutationFailed && other.error == error && other.stackTrace == stackTrace;
  }

  @override
  int get hashCode => error.hashCode ^ stackTrace.hashCode;
}

class MPS<MT, T> {
  MPS({required this.mutationType, required this.data});

  final MT? mutationType;
  final T data;

  @override
  String toString() => 'MPS{mutationType: $mutationType, data: $data}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MPS<MT, T> && other.mutationType == mutationType && other.data == data;
  }

  @override
  int get hashCode => mutationType.hashCode ^ data.hashCode;
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
  HandshakeCompleter<T>? get completer;

  ProviderListenable<Future<T?>> get selectItem;

  Stream<MPS<MT, T>> get selectItemStream => ref
      .streamOf(selectItem, fireImmediately: true)
      .asyncMap((item) => item)
      .whereType<T>()
      .map((item) => asMutationState(item))
      .whereNotNull()
      .doOnData(
        (event) => timedDP(
          '💨💨 Syncronized an item from source ${event.mutationType == null ? '' : "while mutation: ${event.mutationType} is in progress"}',
        ),
      );

  MPS<MT, T>? asMutationState(T item) {
    final currentMutationType = state.valueOrNull?.mutationType;

    return state.map(
      data: (data) => MPS(mutationType: currentMutationType, data: item),
      loading: (loading) {
        if (loading.hasValue) {
          state = AsyncLoading<MPS<MT, T>>().copyWithPrevious(
            AsyncData(MPS(mutationType: currentMutationType, data: item)),
          );
        } else {
          state = AsyncData(MPS(mutationType: currentMutationType, data: item));
        }
        return null;
      },
      error: (error) => MPS(mutationType: currentMutationType, data: item),
    );
  }

  Future<Either<MutationFailure, T>> mutate({
    required MT mutationType,
    required Future<T> Function(T) mutate,
    HandshakeCompleter<T>? completer,
  }) async {
    final currentData = state.valueOrNull?.data;
    if (state.isLoading) {
      return Left(MutationWhileLoading());
    }

    if (currentData == null) {
      return Left(MutationWithoutInitialData());
    }

    state = AsyncLoading<MPS<MT, T>>().copyWithPrevious(
      AsyncData(MPS<MT, T>(mutationType: mutationType, data: currentData)),
    );

    final taskEither = TaskEither<MutationFailure, T>.tryCatch(
      () => mutate(currentData),
      (error, stackTrace) => MutationFailed(error, stackTrace),
    );
    final _completer = completer ?? this.completer;

    final mutateResult = await taskEither.run();

    return mutateResult.fold(
      (mutationFailure) async {
        if (_completer != null) {
          _completer.completeError(mutationFailure);
        }
        state = AsyncData(MPS(mutationType: null, data: currentData));
        // state = mutationFailure
        //     .asAsyncError<MPS<MT, T>>()
        //     .copyWithPrevious(AsyncData(MPS(mutationType: mutationType, data: currentData)));
        return Left(mutationFailure);
      },
      (mutatedData) async {
        if (_completer != null) {
          await _completer.completeAwaitingHandshake(mutatedData);
        }
        state = AsyncData(MPS(mutationType: null, data: mutatedData));
        return Right(mutatedData);
      },
    );
  }

  // Future<Either<MutationFailure, K>> mutateTransitive<K>({
  //   required MT mutationType,
  //   required Future<K> Function() mutate,
  // }) async {
  //   final currentData = state.valueOrNull?.data;
  //   if (state.isLoading) {
  //     return Left(MutationWhileLoading());
  //   }

  //   if (currentData == null) {
  //     return Left(MutationWithoutInitialData());
  //   }

  //   state = AsyncLoading<MPS<MT, T>>().copyWithPrevious(AsyncData(MPS(mutationType: mutationType, data: currentData)));

  //   final taskEither = TaskEither<MutationFailure, K>.tryCatch(
  //     () => mutate(),
  //     (error, stackTrace) => MutationFailed(error, stackTrace),
  //   );
  //   final mutateResult = await taskEither.run();

  //   return mutateResult.fold(
  //     (mutationFailure) {
  //       state = mutationFailure
  //           .asAsyncError<MPS<MT, T>>()
  //           .copyWithPrevious(AsyncData(MPS(mutationType: mutationType, data: currentData)));

  //       return Left(mutationFailure);
  //     },
  //     (mutatedData) {
  //       // provider is in some state, will [hopefully] get updated by eventual fire of updated item.
  //       return Right(mutatedData);
  //     },
  //   );
  // }
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
