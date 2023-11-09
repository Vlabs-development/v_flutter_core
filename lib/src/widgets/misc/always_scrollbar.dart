import 'package:flutter/material.dart';

class AlwaysScrollbar extends StatelessWidget {
  const AlwaysScrollbar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: Theme.of(context).scrollbarTheme.copyWith(
              thumbVisibility: const MaterialStatePropertyAll(true),
            ),
      ),
      child: child,
    );
  }
}

class NeverScrollbar extends StatelessWidget {
  const NeverScrollbar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: Theme.of(context).scrollbarTheme.copyWith(
              thumbVisibility: const MaterialStatePropertyAll(false),
              trackVisibility: const MaterialStatePropertyAll(false),
              thumbColor: const MaterialStatePropertyAll(Colors.transparent),
              trackColor: const MaterialStatePropertyAll(Colors.transparent),
              trackBorderColor: const MaterialStatePropertyAll(Colors.transparent),
            ),
      ),
      child: child,
    );
  }
}
