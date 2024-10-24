import 'package:flutter/material.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

class SeparatedColumn extends StatelessWidget {
  const SeparatedColumn({
    super.key,
    required this.children,
    required this.separator,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.clipBehavior = Clip.none,
    this.childPadding,
  });

  final List<Widget> children;
  final Widget separator;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final Clip clipBehavior;
  final EdgeInsetsGeometry? childPadding;

  @override
  Widget build(BuildContext context) {
    final paddedChildren =
        children.map((child) => childPadding == null ? child : Padding(padding: childPadding!, child: child));

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: paddedChildren.putBetween(separator),
    );
  }
}
