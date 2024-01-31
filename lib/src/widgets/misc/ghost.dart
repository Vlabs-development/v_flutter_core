import 'package:flutter/material.dart';

class Ghost extends StatelessWidget {
  const Ghost({
    required this.child,
    required this.invisible,
    super.key,
  });

  final Widget child;
  final bool invisible;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: invisible ? 0 : 1,
      child: IgnorePointer(
        ignoring: invisible,
        child: ExcludeFocus(
          excluding: invisible,
          child: child,
        ),
      ),
    );
  }
}
