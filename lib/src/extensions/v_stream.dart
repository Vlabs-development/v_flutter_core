import 'dart:async';

import 'package:rxdart/rxdart.dart';

class VStream {
  /// Similar to `Stream.periodic`, this
  /// creates a stream that emits when it is being listened to and then repeatedly firest at [period] intervals.
  ///
  /// The event values are computed by invoking [computation].
  /// The argument to this callback is an integer that starts with 0 (the initial event)
  /// and is incremented for every periodic event.
  static Stream<T?> initialPeriodic<T>(Duration period, [T Function(int)? computation]) {
    T? _computation(int index) => computation == null ? null : computation(index);

    return Stream<T?>.periodic(
      period,
      (computationCount) => _computation(computationCount + 1),
    ).shareValueSeeded(_computation(0));
  }

  /// Generates a stream that emits the current [DateTime] every minute.
  ///
  /// The stream emits the current [DateTime] every minute, with the option to emit the initial tick immediately after being listened to.
  /// The time of the ticks can be offset by a specified duration.
  ///
  /// The function throws an [ArgumentError] if the `tickOffset` is more than 59 seconds.
  static Stream<DateTime> minutely({
    bool initialTick = true,
    Duration tickOffset = Duration.zero,
  }) {
    if (tickOffset > const Duration(seconds: 59)) {
      throw ArgumentError('tickOffset must be less than 59 seconds');
    }

    StreamController<DateTime>? controller;
    Timer? timer;
    DateTime? lastEmittedTime;

    void startTimer() {
      timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        final DateTime now = DateTime.now();
        final DateTime adjustedTime = DateTime(now.year, now.month, now.day, now.hour, now.minute).add(tickOffset);
        if (lastEmittedTime == null ||
            now.isAfter(adjustedTime) &&
                (lastEmittedTime!.minute != now.minute || lastEmittedTime!.second < tickOffset.inSeconds)) {
          lastEmittedTime = now;
          controller!.add(now);
        }
      });
    }

    controller = StreamController<DateTime>(
      onListen: () {
        if (initialTick) {
          final DateTime now = DateTime.now();
          lastEmittedTime = now;
          controller?.add(now);
        }
        startTimer();
      },
      onPause: () => timer?.cancel(),
      onResume: () => startTimer(),
      onCancel: () {
        timer?.cancel();
        controller?.close();
      },
    );

    return controller.stream;
  }
}
