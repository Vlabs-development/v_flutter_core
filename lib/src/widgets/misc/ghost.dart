import 'package:flutter/material.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

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
      child: Uninteractable(
        uninteractable: invisible,
        child: child,
      ),
    );
  }
}
