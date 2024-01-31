import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

/// Currently only supports forward animation.
class SizeThenFadeTransition extends HookWidget {
  const SizeThenFadeTransition({
    required this.child,
    required this.animation,
    this.axisAlignment = 0.0,
    this.opacityDuration = const Duration(milliseconds: 300),
    this.axis = Axis.vertical,
    this.curve = Curves.linear,
    this.reverseCurve,
    super.key,
  });

  final Widget child;
  final Axis axis;
  final Animation<double> animation;
  final double axisAlignment;
  final Duration opacityDuration;
  final Curve curve;
  final Curve? reverseCurve;

  Curve get effectiveReverseCurve => reverseCurve ?? FlippedCurve(curve);

  @override
  Widget build(BuildContext context) {
    final tween = Tween<double>(begin: 0, end: 1);

    return SizeTransition(
      axis: axis,
      axisAlignment: axisAlignment,
      sizeFactor: tween.animate(
        CurvedAnimation(
          parent: animation,
          curve: curve,
          reverseCurve: effectiveReverseCurve,
        ),
      ),
      child: FadeTransition(
        opacity: tween.animate(
          CurvedAnimation(
            parent: useChainedAnimationController(
              animation,
              duration: opacityDuration,
            ),
            curve: curve,
            reverseCurve: effectiveReverseCurve,
          ),
        ),
        child: child,
      ),
    );
  }
}
