import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
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

/// A widget that adapts its layout based on predefined window size classes.
/// It considers the width of the viewport to determine the window size class.
/// [orElse] is the default widget to be displayed if no other widget is specified,
/// and when the viewport width is larger than all the defined size class layouts.
///
/// Eg: if compact (till 600) and medium (till 840) are defined, and the viewport width is 1000, then the [orElse] widget will be displayed.
///
/// Smaller window sizes try to match the larger window sizes if not defined.
/// Eg: if neither compact nor medium is defined, but expanded is defined, then expanded will be displayed for compact and medium window sizes.
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
    final effectiveSize = () {
      final _windowSizeClass = size?.windowSizeClass;
      if (_windowSizeClass != null) {
        return _windowSizeClass;
      }

      if (kIsWeb) {
        return WindowSizeClass.large;
      } else {
        if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
          return WindowSizeClass.expanded;
        }
        if (Platform.isIOS || Platform.isAndroid) {
          return WindowSizeClass.compact;
        }
      }

      return WindowSizeClass.expanded;
    }();
    final widgetBuilder = useMemoized(
      () => switch (effectiveSize) {
        WindowSizeClass.compact => compact ?? medium ?? expanded ?? large ?? extraLarge ?? orElse,
        WindowSizeClass.medium => medium ?? expanded ?? large ?? extraLarge ?? orElse,
        WindowSizeClass.expanded => expanded ?? large ?? extraLarge ?? orElse,
        WindowSizeClass.large => large ?? extraLarge ?? orElse,
        WindowSizeClass.extraLarge => extraLarge ?? orElse,
      },
      [effectiveSize],
    );

    return widgetBuilder(context);
  }
}
