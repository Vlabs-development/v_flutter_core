import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:v_core/v_core.dart';

class DelegatingScaffold extends HookConsumerWidget {
  const DelegatingScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final behavior = context.requireExtension<ScaffoldBehavior>();

    return Scaffold(
      extendBody: behavior.extendBody ?? false,
      extendBodyBehindAppBar: behavior.extendBodyBehindAppBar ?? false,
      appBar: behavior.appBar,
      body: behavior.body?.call(context, null) ?? const SizedBox(),
      floatingActionButton: behavior.floatingActionButton,
      floatingActionButtonLocation: behavior.floatingActionButtonLocation,
      floatingActionButtonAnimator: behavior.floatingActionButtonAnimator,
      persistentFooterButtons: behavior.persistentFooterButtons,
      persistentFooterAlignment: behavior.persistentFooterAlignment ?? AlignmentDirectional.centerEnd,
      drawer: behavior.drawer,
      onDrawerChanged: behavior.onDrawerChanged,
      endDrawer: behavior.endDrawer,
      onEndDrawerChanged: behavior.onEndDrawerChanged,
      drawerScrimColor: behavior.drawerScrimColor,
      backgroundColor: behavior.backgroundColor,
      bottomNavigationBar: behavior.bottomNavigationBar,
      bottomSheet: behavior.bottomSheet,
      resizeToAvoidBottomInset: behavior.resizeToAvoidBottomInset,
      primary: behavior.primary ?? true,
      drawerDragStartBehavior: behavior.drawerDragStartBehavior ?? DragStartBehavior.start,
      drawerEdgeDragWidth: behavior.drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: behavior.drawerEnableOpenDragGesture ?? true,
      endDrawerEnableOpenDragGesture: behavior.endDrawerEnableOpenDragGesture ?? true,
    );
  }
}
