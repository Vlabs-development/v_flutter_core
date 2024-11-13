import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'tracked_stream.dart';

/// A utility class to create streams with events and delays in a declarative way.
///
/// Example:
/// ```dart
/// final modular = ModularStream<int>([
///   100.milliseconds,
///   1,
///   2,
///   20.milliseconds,
///   3,
/// ], doBeforeData: (data) {
///   print('Before adding $data');
/// });
/// ```
class ModularStream<T> {
  ModularStream(this._events) {
    for (final event in _events) {
      if (event is! Duration && event is! T) {
        throw ArgumentError(
          'Invalid event type: ${event.runtimeType}. '
          'Events must be either Duration or $T',
        );
      }
    }
    _subject = BehaviorSubject<T>(onListen: () => _emitEvents());
    _tracker = TrackedStream(_subject.stream);
  }

  final List<Object> _events;
  late final BehaviorSubject<T> _subject;
  late final TrackedStream<T> _tracker;

  void Function(T data)? doBeforeData;

  Stream<T> get stream => _tracker.stream;

  BehaviorSubject<T> get subject => _subject;

  bool get isClosed => _subject.isClosed;

  T? get currentValue => _subject.valueOrNull;

  int get subscriptionCount => _tracker.subscriptionCount;
  int get cancelCount => _tracker.cancelCount;
  int get activeSubscriptionCount => _tracker.activeSubscriptionCount;
  int get emissionCount => _tracker.emissionCount;
  int get doneCount => _tracker.doneCount;

  Future<void> _emitEvents() async {
    for (final event in _events) {
      if (event is Duration) {
        await Future.delayed(event);

      if (T == Duration) {
        _subject.add(event as T);
      }

      } else if (event is T) {
        final typedEvent = event as T;
        doBeforeData?.call(typedEvent);
        _subject.add(typedEvent);
      } else {
        throw ArgumentError(
          'Invalid event type: ${event.runtimeType}. '
          'Events must be either Duration or $T',
        );
      }
    }
    await _subject.close();
  }
}

extension ModularStreamX on List<Object> {
  ModularStream<T> modular<T>() => ModularStream<T>(this);
}
