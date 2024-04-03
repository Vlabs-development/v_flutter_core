import 'dart:async';

import 'package:flutter/foundation.dart';

class NotifyEveryMinute extends ChangeNotifier {
  NotifyEveryMinute() {
    _registerTimerThatNotifiesOnNextMinute();
  }

  Timer? _timer;

  void _registerTimerThatNotifiesOnNextMinute() {
    final now = DateTime.now();
    final nextMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    final durationTillNextMinute = nextMinute.difference(now);

    _timer = Timer(durationTillNextMinute, () {
      _timer?.cancel();
      notifyListeners();
      _registerTimerThatNotifiesOnNextMinute();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
