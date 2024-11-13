import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

abstract class CreationFailure {
  AsyncError<T> asAsyncError<T>() => AsyncError<T>('CreationFailure', StackTrace.current);
}

class CreationWhileLoading implements CreationFailure {
  @override
  AsyncError<T> asAsyncError<T>() => AsyncError<T>('CreationWhileLoading', StackTrace.current);
}

class CreationFailed implements CreationFailure {
  CreationFailed(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;

  @override
  AsyncError<T> asAsyncError<T>() => AsyncError<T>(error, stackTrace);
}

class CPS<CT, T> {
  CPS({required this.creationType, required this.data});

  final List<CT> creationType;
  final T? data;

  @override
  String toString() => 'CPS{creationType: $creationType, data: $data}';
}

extension CPSAsyncValueExtension<CT, T> on AsyncValue<CPS<CT, T>> {
  bool isInProgress(CT creationType) {
    return maybeWhen(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      loading: () => valueOrNull?.creationType.contains(creationType) ?? false,
      orElse: () => false,
    );
  }
}

// ignore: invalid_use_of_internal_member
mixin CreationProvider<CT, T> on BuildlessAutoDisposeStreamNotifier<CPS<CT, T>> {
  void onCreated(T? previous, T next) {}

  CPS<CT, T> asCreationState(T item) => state.map<CPS<CT, T>>(
        data: (data) => CPS(creationType: [], data: item),
        loading: (loading) => CPS(creationType: loading.valueOrNull?.creationType ?? [], data: item),
        error: (error) => CPS(creationType: [], data: item),
      );

  Future<Either<CreationFailure, T>> create({
    required CT creationType,
    required Future<T> Function() create,
    Completer<T>? completer,
  }) async {
    final currentData = state.valueOrNull?.data;

    if (state.isInProgress(creationType)) {
      return Left(CreationWhileLoading());
    }

    state = AsyncLoading<CPS<CT, T>>().copyWithPrevious(
      AsyncData(CPS(creationType: withCreationType(creationType), data: null)),
    );

    final taskEither = TaskEither<CreationFailure, T>.tryCatch(
      () => create(),
      CreationFailed.new,
    );
    final _completer = completer;
    final createResult = await taskEither.run();

    return createResult.fold(
      (creationFailure) {
        if (_completer == null) {
          state = creationFailure.asAsyncError<CPS<CT, T>>().copyWithPrevious(
                AsyncData(CPS(creationType: withoutCreationType(creationType), data: currentData)),
              );
        } else {
          completer?.completeError(creationFailure);
        }

        return Left(creationFailure);
      },
      (createdData) {
        if (_completer == null) {
          state = AsyncData(CPS(creationType: withoutCreationType(creationType), data: createdData));
        } else {
          completer?.complete(createdData);
        }
        onCreated(currentData, createdData);
        return Right(createdData);
      },
    );
  }

  List<CT> withCreationType(CT creationType) {
    return <CT>{...state.valueOrNull?.creationType ?? [], creationType}.toList();
  }

  List<CT> withoutCreationType(CT creationType) {
    return <CT>{...state.valueOrNull?.creationType ?? []}.toList()..remove(creationType);
  }
}
