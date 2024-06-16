import 'package:flutter/material.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

/// Essentially an [AnimatedOpacity] in pair with a [IgnorePointer]
class AnimatedGhost extends StatelessWidget {
  const AnimatedGhost({
    required this.child,
    required this.invisible,
    required this.duration,
    this.curve = Curves.linear,
    super.key,
  });

  final Widget child;
  final bool invisible;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: duration,
      curve: curve,
      opacity: invisible ? 0 : 1,
      child: Uninteractable(
        uninteractable: invisible,
        child: child,
      ),
    );
  }
}
