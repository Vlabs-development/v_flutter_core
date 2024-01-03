import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DebugContainer extends StatelessWidget {
  const DebugContainer({
    required this.child,
    required this.debugChild,
    super.key,
  });

  final Widget child;
  final Widget debugChild;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      return debugChild;
    }

    return child;
  }
}
