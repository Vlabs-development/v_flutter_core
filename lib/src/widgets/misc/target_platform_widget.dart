import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

WidgetBuilder? _builderOrNull(Widget? widget) => widget == null ? null : ((_) => widget);
WidgetBuilder _builder(Widget widget) => (context) => widget;

class TargetPlatformWidget extends HookWidget {
  TargetPlatformWidget({
    super.key,
    required Widget orElse,
    Widget? mobile,
    Widget? desktop,
    Widget? web,
  })  : mobile = _builderOrNull(mobile),
        desktop = _builderOrNull(desktop),
        web = _builderOrNull(web),
        orElse = _builder(orElse);

  const TargetPlatformWidget.builder({
    super.key,
    this.mobile,
    this.desktop,
    this.web,
    required this.orElse,
  });

  final WidgetBuilder? mobile;
  final WidgetBuilder? desktop;
  final WidgetBuilder? web;
  final WidgetBuilder orElse;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web?.call(context) ?? orElse(context);
    }

    final platform = Theme.of(context).platform;

    return switch (platform) {
      TargetPlatform.android || TargetPlatform.iOS => mobile?.call(context) ?? orElse(context),
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux =>
        desktop?.call(context) ?? orElse(context),
      TargetPlatform.fuchsia => orElse(context),
    };
  }
}
