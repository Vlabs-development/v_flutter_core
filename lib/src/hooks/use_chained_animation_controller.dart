import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

AnimationController useChainedAnimationController(
  Animation<dynamic> parent, {
  Duration? duration,
  Duration? reverseDuration,
  String? debugLabel,
  double initialValue = 0,
  double lowerBound = 0,
  double upperBound = 1,
  TickerProvider? vsync,
  AnimationBehavior animationBehavior = AnimationBehavior.normal,
  List<Object?>? keys,
}) {
  final controller = useAnimationController(
    duration: duration,
    reverseDuration: reverseDuration,
    debugLabel: debugLabel,
    initialValue: initialValue,
    lowerBound: lowerBound,
    upperBound: upperBound,
    vsync: vsync,
    animationBehavior: animationBehavior,
    keys: keys,
  );

  void onStatusChanged(AnimationStatus parentStatus) {
    if (parentStatus == AnimationStatus.completed) {
      controller.forward();
    }
    if (parentStatus == AnimationStatus.dismissed) {
      controller.reverse();
    }
  }

  usePlainEffectOnce(
    () {
      if (parent.status == AnimationStatus.completed) {
        controller.animateTo(upperBound, duration: Duration.zero);
      }
      if (parent.status == AnimationStatus.dismissed) {
        controller.animateTo(lowerBound, duration: Duration.zero);
      }
    },
  );

  useEffect(
    () {
      parent.addStatusListener(onStatusChanged);
      return () => parent.removeStatusListener(onStatusChanged);
    },
    [parent],
  );

  return controller;
}
