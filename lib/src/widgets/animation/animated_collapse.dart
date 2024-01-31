import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

class AnimatedCollapse extends HookWidget {
  const AnimatedCollapse({
    super.key,
    required this.child,
    required this.collapsed,
    required this.duration,
    this.axis = Axis.vertical,
    this.axisAlignment = 0.0,
    this.curve = Curves.linear,
    this.reverseCurve,
    this.reverseDuration,
  });

  final Widget? child;
  final bool collapsed;
  final Axis axis;
  final double axisAlignment;
  final Curve curve;
  final Duration duration;
  final Curve? reverseCurve;
  final Duration? reverseDuration;

  Curve get effectiveReverseCurve => reverseCurve ?? FlippedCurve(curve);

  @override
  Widget build(BuildContext context) {
    final animation = useAnimationController(
      duration: duration,
      reverseDuration: reverseDuration,
      initialValue: collapsed ? 0 : 1,
    );

    useValueListener(collapsed, () {
      if (collapsed) {
        animation.reverse();
      } else {
        animation.forward();
      }
    });

    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animation,
        curve: curve,
        reverseCurve: effectiveReverseCurve,
      ),
      axis: axis,
      axisAlignment: axisAlignment,
      child: child,
    );
  }
}
