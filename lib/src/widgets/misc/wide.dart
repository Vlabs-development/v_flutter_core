import 'package:flutter/material.dart';

class Wide extends StatelessWidget {
  const Wide({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: double.infinity),
      child: child,
    );
  }
}
