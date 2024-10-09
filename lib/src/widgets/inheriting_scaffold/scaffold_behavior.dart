// ignore_for_file: annotate_overrides

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'scaffold_behavior.tailor.dart';

typedef ChildedBuilder = Widget Function(BuildContext context, Widget? child);

@TailorMixinComponent()
class ScaffoldBehavior extends ThemeExtension<ScaffoldBehavior> with _$ScaffoldBehaviorTailorMixin {
  ScaffoldBehavior({
    this.extendBody,
    this.extendBodyBehindAppBar,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.persistentFooterAlignment,
    this.drawer,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.drawerScrimColor,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.resizeToAvoidBottomInset,
    this.primary,
    this.drawerDragStartBehavior,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture,
    this.endDrawerEnableOpenDragGesture,
  });

  final bool? extendBody;
  final bool? extendBodyBehindAppBar;
  final PreferredSizeWidget? appBar;
  final ChildedBuilder? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final AlignmentDirectional? persistentFooterAlignment;
  final Widget? drawer;
  final DrawerCallback? onDrawerChanged;
  final Widget? endDrawer;
  final DrawerCallback? onEndDrawerChanged;
  final Color? drawerScrimColor;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool? resizeToAvoidBottomInset;
  final bool? primary;
  final DragStartBehavior? drawerDragStartBehavior;
  final double? drawerEdgeDragWidth;
  final bool? drawerEnableOpenDragGesture;
  final bool? endDrawerEnableOpenDragGesture;

  @override
  ScaffoldBehavior merge(ScaffoldBehavior? other) {
    if (other == null) {
      return this;
    }
    return ScaffoldBehavior(
      extendBody: extendBody ?? other.extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar ?? other.extendBodyBehindAppBar,
      appBar: appBar ?? other.appBar,
      body: mergeChildedBuilder(body, other.body),
      floatingActionButton: floatingActionButton ?? other.floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation ?? other.floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator ?? other.floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons ?? other.persistentFooterButtons,
      persistentFooterAlignment: persistentFooterAlignment ?? other.persistentFooterAlignment,
      drawer: drawer ?? other.drawer,
      onDrawerChanged: onDrawerChanged ?? other.onDrawerChanged,
      endDrawer: endDrawer ?? other.endDrawer,
      onEndDrawerChanged: onEndDrawerChanged ?? other.onEndDrawerChanged,
      drawerScrimColor: drawerScrimColor ?? other.drawerScrimColor,
      backgroundColor: backgroundColor ?? other.backgroundColor,
      bottomNavigationBar: bottomNavigationBar ?? other.bottomNavigationBar,
      bottomSheet: bottomSheet ?? other.bottomSheet,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? other.resizeToAvoidBottomInset,
      primary: primary ?? other.primary,
      drawerDragStartBehavior: drawerDragStartBehavior ?? other.drawerDragStartBehavior,
      drawerEdgeDragWidth: drawerEdgeDragWidth ?? other.drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture ?? other.drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture ?? other.endDrawerEnableOpenDragGesture,
    );
  }
}

ChildedBuilder? mergeChildedBuilder(
  ChildedBuilder? a,
  ChildedBuilder? b,
) {
  if (a == null && b == null) {
    return null;
  }
  if (a == null) {
    return b;
  }
  if (b == null) {
    return a;
  }
  return (context, child) {
    return Builder(
      builder: (context) {
        return b(
          context,
          Builder(
            builder: (context) {
              return a(context, child);
            },
          ),
        );
      },
    );
  };
}
