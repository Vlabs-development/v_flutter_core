import 'dart:async';

class TrackedStream<T> {
  TrackedStream(this._stream);

  final Stream<T> _stream;
  int _subscriptionCount = 0;
  int _cancelCount = 0;
  int _emissionCount = 0;
  int _doneCount = 0;
  final List<StreamSubscription<T>> _activeSubscriptions = [];

  int get subscriptionCount => _subscriptionCount;

  int get cancelCount => _cancelCount;

  int get activeSubscriptionCount => _activeSubscriptions.length;

  int get emissionCount => _emissionCount;

  int get doneCount => _doneCount;

  Stream<T> get stream => Stream.multi(
        (controller) {
          final subscription = _stream.listen(
            (data) {
              _emissionCount++;
              controller.add(data);
            },
            onError: controller.addError,
            onDone: () {
              _doneCount++;
              controller.close();
            },
          );

          _subscriptionCount++;
          _activeSubscriptions.add(subscription);

          controller.onCancel = () {
            _cancelCount++;
            _activeSubscriptions.remove(subscription);
            return subscription.cancel();
          };
        },
        isBroadcast: _stream.isBroadcast,
      );

  bool get isBroadcast => _stream.isBroadcast;
}
