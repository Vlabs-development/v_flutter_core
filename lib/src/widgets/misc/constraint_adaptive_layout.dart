import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

Map<double, WidgetBuilder> _builderOfMap(Map<double, Widget> widgets) => widgets.map(
      (fromWidth, child) => MapEntry(fromWidth, (context) => child),
    );

WidgetBuilder _builder(Widget child) => (context) => child;

/// The `ConstraintAdaptiveLayout` displays different widgets depending on the
/// width constraints. It requires specifying a widget [aboveZero] for the >= 0 width constraint
/// and a map of double->widget for various width breakpoints.
class ConstraintAdaptiveLayout extends HookWidget {
  ConstraintAdaptiveLayout({
    super.key,
    required Widget aboveZero,
    required Map<double, Widget> breakpoints,
  })  : above = _builderOfMap(breakpoints),
        aboveZero = _builder(aboveZero);

  const ConstraintAdaptiveLayout.builder({
    super.key,
    required this.above,
    required this.aboveZero,
  });

  final Map<double, WidgetBuilder> above;
  final WidgetBuilder aboveZero;

  @override
  Widget build(BuildContext context) {
    assert(!above.containsKey(0), 'Define aboveZero for >=0 width constraint');
    final _aboveWithoutZero = above..remove(0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final _above = {0: aboveZero, ..._aboveWithoutZero}.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

        final widgetBuilder = _above.lastWhere((entry) => entry.key <= maxWidth, orElse: () => _above.first).value;
        return widgetBuilder(context);
      },
    );
  }
}
