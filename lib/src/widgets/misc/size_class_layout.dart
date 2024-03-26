import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

enum WindowSizeClass { compact, medium, expanded, large, extraLarge }

WidgetBuilder? _builderOrNull(Widget? widget) => widget == null ? null : ((_) => widget);
WidgetBuilder _builder(Widget widget) => (context) => widget;

extension DoubleX on double {
  WindowSizeClass get toWindowSizeClass {
    return switch (this) {
      < 600 => WindowSizeClass.compact,
      < 840 => WindowSizeClass.medium,
      < 1200 => WindowSizeClass.expanded,
      < 1600 => WindowSizeClass.large,
      _ => WindowSizeClass.extraLarge,
    };
  }
}

extension MediaQueryDataX on MediaQueryData {
  WindowSizeClass get windowSizeClass => size.width.toWindowSizeClass;
}

extension SizeX on Size {
  WindowSizeClass get windowSizeClass => width.toWindowSizeClass;
}

class SizeClassLayout extends HookWidget {
  SizeClassLayout({
    super.key,
    required Widget orElse,
    Widget? compact,
    Widget? medium,
    Widget? expanded,
    Widget? large,
    Widget? extraLarge,
  })  : compact = _builderOrNull(compact),
        medium = _builderOrNull(medium),
        expanded = _builderOrNull(expanded),
        large = _builderOrNull(large),
        extraLarge = _builderOrNull(extraLarge),
        orElse = _builder(orElse);

  const SizeClassLayout.builder({
    super.key,
    this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
    required this.orElse,
  });

  final WidgetBuilder? compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;
  final WidgetBuilder? large;
  final WidgetBuilder? extraLarge;
  final WidgetBuilder orElse;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.maybeSizeOf(context);
    assert(size != null, 'Size is null, cannot compute WindowSizeClass');
    final effectiveSize = size?.windowSizeClass ?? (kIsWeb ? WindowSizeClass.expanded : WindowSizeClass.compact);
    final widgetBuilder = useMemoized(
      () =>
          switch (effectiveSize) {
            WindowSizeClass.compact => compact,
            WindowSizeClass.medium => medium,
            WindowSizeClass.expanded => expanded,
            WindowSizeClass.large => large,
            WindowSizeClass.extraLarge => extraLarge,
          } ??
          orElse,
      [effectiveSize],
    );

    return widgetBuilder(context);
  }
}
