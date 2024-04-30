import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

class StreamObserver<T> {
  StreamObserver(Stream<T> stream) {
    _listenCountSubject = BehaviorSubject<int>();
    _emitCountSubject = BehaviorSubject<int>();
    _cancelCountSubject = BehaviorSubject<int>();
    _doneCountSubject = BehaviorSubject<int>();
    this.stream = stream.doOnListen(() {
      debugPrint(' >> listen');
      _listenCountSubject.add(_listenCountSubject.valueOrNull ?? 0 + 1);
    }).doOnData((event) {
      debugPrint(' >> data');
      _emitCountSubject.add(_emitCountSubject.valueOrNull ?? 0 + 1);
    }).doOnCancel(() {
      debugPrint(' >> cancel');
      _cancelCountSubject.add(_cancelCountSubject.valueOrNull ?? 0 + 1);
      if (!stream.isBroadcast) {
        _cancelCountSubject.close();
        _listenCountSubject.close();
      }
    }).doOnDone(() {
      debugPrint(' >> done');
      _doneCountSubject.add(_doneCountSubject.valueOrNull ?? 0 + 1);
      if (!stream.isBroadcast) {
        _doneCountSubject.close();
      }
    });
    addTearDown(() => dispose());
  }

  late Stream<T> stream;

  late final BehaviorSubject<int> _listenCountSubject;
  late final BehaviorSubject<int> _emitCountSubject;
  late final BehaviorSubject<int> _cancelCountSubject;
  late final BehaviorSubject<int> _doneCountSubject;

  Stream<int> get listenCount => _listenCountSubject.stream;
  Stream<int> get emitCount => _emitCountSubject.stream;
  Stream<int> get cancelCount => _cancelCountSubject.stream;
  Stream<int> get doneCount => _doneCountSubject.stream;

  void dispose() {
    _listenCountSubject.close();
    _emitCountSubject.close();
    _cancelCountSubject.close();
    _doneCountSubject.close();
  }
}
