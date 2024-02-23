import 'package:flutter/material.dart';

class Uninteractable extends StatelessWidget {
  const Uninteractable({
    required this.child,
    this.uninteractable = false,
    super.key,
  });

  final Widget child;
  final bool uninteractable;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: uninteractable,
      child: ExcludeFocus(
        excluding: uninteractable,
        child: child,
      ),
    );
  }
}
