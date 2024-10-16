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
              thumbVisibility: const WidgetStatePropertyAll(true),
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
              thumbVisibility: const WidgetStatePropertyAll(false),
              trackVisibility: const WidgetStatePropertyAll(false),
              thumbColor: const WidgetStatePropertyAll(Colors.transparent),
              trackColor: const WidgetStatePropertyAll(Colors.transparent),
              trackBorderColor: const WidgetStatePropertyAll(Colors.transparent),
            ),
      ),
      child: child,
    );
  }
}
