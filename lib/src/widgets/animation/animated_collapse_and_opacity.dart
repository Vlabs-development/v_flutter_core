import 'package:flutter/widgets.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

class AnimatedCollapseAndOpacity extends StatelessWidget {
  const AnimatedCollapseAndOpacity({
    required this.child,
    required this.visible,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
    this.axisAlignment = -1.0,
    this.axis = Axis.vertical,
    this.curve = Curves.linear,
    this.reverseCurve,
    super.key,
  });

  final Widget child;
  final Axis axis;
  final bool visible;
  final double axisAlignment;
  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;
  final Curve? reverseCurve;

  double get state => visible ? 1 : 0;

  Curve get effectiveReverseCurve => reverseCurve ?? FlippedCurve(curve);

  @override
  Widget build(BuildContext context) {
    return AnimatedCollapse(
      collapsed: !visible,
      duration: duration,
      axis: axis,
      curve: curve,
      axisAlignment: axisAlignment,
      reverseCurve: effectiveReverseCurve,
      reverseDuration: reverseDuration,
      child: AnimatedOpacity(
        opacity: state,
        duration: duration,
        curve: (visible ? curve : effectiveReverseCurve),
        child: child,
      ),
    );
  }
}
