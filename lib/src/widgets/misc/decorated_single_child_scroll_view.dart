import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A scroll view that allows adding start and end decorations,
/// which can be pinned or scroll with the content.
///
/// This widget extends the functionality of `SingleChildScrollView`
/// by adding optional `startDecoration` and `endDecoration` widgets.
class DecoratedSingleChildScrollView extends StatelessWidget {
  const DecoratedSingleChildScrollView({
    super.key,
    required this.child,
    this.startDecoration = const SizedBox(),
    this.endDecoration = const SizedBox(),
    this.pinStartDecoration = true,
    this.pinEndDecoration = true,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.primary,
    this.physics,
    this.controller,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  final Widget child;
  final Widget startDecoration;
  final Widget endDecoration;
  final bool pinStartDecoration;
  final bool pinEndDecoration;

  final Axis scrollDirection;
  final bool reverse;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final DragStartBehavior dragStartBehavior;
  final Clip clipBehavior;
  final String? restorationId;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pinStartDecoration) startDecoration else const SizedBox(),
        Expanded(
          child: SingleChildScrollView(
            key: key,
            scrollDirection: scrollDirection,
            reverse: reverse,
            padding: padding,
            primary: primary,
            physics: physics,
            controller: controller,
            dragStartBehavior: dragStartBehavior,
            clipBehavior: clipBehavior,
            restorationId: restorationId,
            keyboardDismissBehavior: keyboardDismissBehavior,
            child: Builder(
              builder: (context) => Stack(
                children: [
                  if (pinStartDecoration) const SizedBox() else startDecoration,
                  if (pinEndDecoration) const SizedBox() else Positioned(bottom: 0, child: endDecoration),
                  child,
                ],
              ),
            ),
          ),
        ),
        if (pinEndDecoration) endDecoration else const SizedBox(),
      ],
    );
  }
}
