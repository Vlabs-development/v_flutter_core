import 'package:riverpod/riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

/// A testing utility which creates a [ProviderContainer] and automatically
/// disposes it at the end of the test.
ProviderContainer createContainer({
  ProviderContainer? parent,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  // Create a ProviderContainer, and optionally allow specifying parameters.
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides,
    observers: observers,
  );

  // When the test ends, dispose the container.
  addTearDown(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    container.dispose();
  });

  return container;
}

extension X on ProviderContainer {
  T testRead<T>(ProviderListenable<T> provider) {
    final subscription = listen<T>(provider, (_, __) {});

    addTearDown(subscription.close);

    return subscription.read();
  }

  Stream<T> streamOfAsyncData<T>(ProviderListenable<AsyncValue<T>> provider) {
    final subject = ReplaySubject<T>();

    final subscription = listen(provider, (_, next) {
      next.whenData((value) => subject.add(value));
    });
    addTearDown(subscription.close);
    addTearDown(subject.close);

    return subject.stream;
  }

  Stream<AsyncValue<T>> streamOfAsyncValue<T>(ProviderListenable<AsyncValue<T>> provider) {
    final subject = ReplaySubject<AsyncValue<T>>();

    final subscription = listen(
      provider,
      // fireImmediately: true,
      (previous, next) {
        print('streamOfAsyncValue___________PREVIOUS: $previous NEXT: $next');
        subject.add(next);
      },
    );
    addTearDown(subscription.close);
    addTearDown(subject.close);

    return subject.stream;
  }
}
