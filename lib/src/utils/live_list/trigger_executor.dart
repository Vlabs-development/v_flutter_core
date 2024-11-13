// ignore_for_file: sort_constructors_first

import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

class TriggerExecutor<ID, T> {
  TriggerExecutor({
    required this.fetchItem,
  }) {
    _triggerSubscription = _triggerSubject.listen((id) => _handleTrigger(id));
  }

  StreamSubscription<ID>? _triggerSubscription;

  final ReaderTaskEither<ID, Object?, T> fetchItem;

  final Map<ID, Completer<T>> _completers = {};

  final BehaviorSubject<ID> _triggerSubject = BehaviorSubject<ID>(sync: true);
  Stream<ID> get triggerStream => _triggerSubject;

  final BehaviorSubject<T> _itemSubject = BehaviorSubject<T>(sync: true);
  Stream<T> get itemStream => _itemSubject;

  final Map<ID, int> _triggerCounts = {};

  void add(ID id) => _triggerSubject.add(id);

  Either<Future<T>, Completer<T>> deferItemTrigger(ID id) {
    final existingCompleter = _completers[id];
    if (existingCompleter != null) {
      return Left(existingCompleter.future);
    }

    final completer = Completer<T>();
    _completers[id] = completer;
    completer.future.then((item) async {
      _completers.remove(id);

      if (_triggerCounts[id] == null || _triggerCounts[id] == 0) {
        _itemSubject.add(item);
      }

      final triggerCount = _triggerCounts[id] ?? 0;
      _triggerCounts[id] = 0;
      switch (triggerCount) {
        case 0:
        case 1:
          _itemSubject.add(item);
          Right(item);
        default:
          _fetchItem(id, fallback: item);
      }
    }).catchError((error, stack) {
      _completers.remove(id);
      final triggerCount = _triggerCounts[id] ?? 0;
      _triggerCounts[id] = 0;

      if (triggerCount > 0) {
        _fetchItem(id);
      }
    });

    return Right(completer);
  }

  Future<void> _handleTrigger(ID id) async {
    final existingCompleter = _completers[id];

    if (existingCompleter == null) {
      await _fetchItem(id);
    }

    _triggerCounts[id] = (_triggerCounts[id] ?? 0) + 1;
  }

  Future<Either<Object?, T>> _fetchItem(ID id, {T? fallback}) async {
    final item = await fetchItem.run(id);
    item.match(
      (l) {
        if (fallback != null) {
          _itemSubject.add(fallback);
        }
      },
      (updatedItem) => _itemSubject.add(updatedItem),
    );
    return item;
  }

  void dispose() {
    _triggerSubscription?.cancel();
  }
}
