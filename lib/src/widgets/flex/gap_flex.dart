import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

class GapFlex extends StatelessWidget {
  const GapFlex({
    required this.children,
    required this.direction,
    required this.gap,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.clipBehavior = Clip.none,
    super.key,
  });

  final List<Widget> children;
  final Axis direction;
  final double gap;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return SeparatedFlex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      clipBehavior: clipBehavior,
      separator: Gap(gap),
      children: children,
    );
  }
}
