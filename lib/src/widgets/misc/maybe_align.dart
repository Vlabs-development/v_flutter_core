import 'package:flutter/material.dart';

class MaybeAlign extends StatelessWidget {
  const MaybeAlign({
    required this.child,
    required this.alignment,
    super.key,
  });

  final Widget child;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final _alignment = alignment;

    if (_alignment != null) {
      return Align(alignment: _alignment, child: child);
    }

    return child;
  }
}
