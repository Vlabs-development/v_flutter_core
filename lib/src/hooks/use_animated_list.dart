import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

_AnimatedListHookState useAnimatedList({
  AnimatedRemovedItemBuilder? removedItemBuilder,
  Duration? removeDuration,
}) {
  final key = useGlobalKey<AnimatedListState>();
  return useMemoized(
    () => _AnimatedListHookState(
      key: key,
      removedItemBuilder: removedItemBuilder,
      removeDuration: removeDuration,
    ),
  );
}

class _AnimatedListHookState {
  _AnimatedListHookState({
    required this.key,
    this.removedItemBuilder,
    this.removeDuration,
  });

  final GlobalKey<AnimatedListState> key;
  final AnimatedRemovedItemBuilder? removedItemBuilder;
  final Duration? removeDuration;

  AnimatedListState get state {
    final currentState = key.currentState;
    if (currentState == null) {
      throw 'useAnimatedList() state is null. Ensure `.key` is passed to an [AnimatedList]';
    }
    return currentState;
  }

  void removeItemAt(int index, {AnimatedRemovedItemBuilder? removedItemBuilder, Duration? duration}) {
    final effectiveRemoveItemBuilder = removedItemBuilder ?? this.removedItemBuilder;
    if (effectiveRemoveItemBuilder == null) {
      throw 'AnimatedRemovedItemBuilder was not supplied!';
    }

    final effectiveDuration = duration ?? removeDuration;
    if (effectiveDuration == null) {
      state.removeItem(
        index,
        effectiveRemoveItemBuilder,
      );
    } else {
      state.removeItem(
        index,
        effectiveRemoveItemBuilder,
        duration: effectiveDuration,
      );
    }
  }
}
