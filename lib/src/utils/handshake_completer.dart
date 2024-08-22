import 'dart:async';

class HandshakeCompleter<T> {
  final Completer<T> _completer = Completer<T>();
  final Completer<void> _handshakeCompleter = Completer<void>();
  bool _requiresHandshake = false;
  bool _isHandshaked = false;

  Future<T> get future => _completer.future;
  Future<void> get handshakedFuture => _handshakeCompleter.future;

  bool get isHandshaked => _isHandshaked;
  bool get isCompleted => _completer.isCompleted;
  bool get requiresHandshake => _requiresHandshake;

  void setRequiresHandshake() => _requiresHandshake = true;

  Future<T> completeAwaitingHandshake([FutureOr<T>? value]) async {
    _completer.complete(value);
    if (requiresHandshake) {
      await handshakedFuture;
    }
    return future;
  }

  // Future<T> completeErrorAwaitingHandshake(Object error, [StackTrace? stackTrace]) async {
  //   _completer.completeError(error, stackTrace);
  //   if (requiresHandshake) {
  //     await handshakedFuture;
  //   }
  //   return future;
  // }

  void completeError(Object error, [StackTrace? stackTrace]) {
    return _completer.completeError(error, stackTrace);
  }

  void handshake() {
    if (!_completer.isCompleted) {
      throw StateError('($hashCode) Cannot handshake before the completer is completed.');
    }
    if (_isHandshaked) {
      throw StateError('($hashCode) Handshake has already been called.');
    }
    _isHandshaked = true;
    _handshakeCompleter.complete();
  }
}
