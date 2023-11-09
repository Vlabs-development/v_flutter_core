// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element, unnecessary_cast

part of 'scaffold_behavior.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$ScaffoldBehaviorTailorMixin on ThemeExtension<ScaffoldBehavior> {
  bool? get extendBody;
  bool? get extendBodyBehindAppBar;
  PreferredSizeWidget? get appBar;
  Widget Function(BuildContext, Widget?)? get body;
  Widget? get floatingActionButton;
  FloatingActionButtonLocation? get floatingActionButtonLocation;
  FloatingActionButtonAnimator? get floatingActionButtonAnimator;
  List<Widget>? get persistentFooterButtons;
  AlignmentDirectional? get persistentFooterAlignment;
  Widget? get drawer;
  void Function(bool)? get onDrawerChanged;
  Widget? get endDrawer;
  void Function(bool)? get onEndDrawerChanged;
  Color? get drawerScrimColor;
  Color? get backgroundColor;
  Widget? get bottomNavigationBar;
  Widget? get bottomSheet;
  bool? get resizeToAvoidBottomInset;
  bool? get primary;
  DragStartBehavior? get drawerDragStartBehavior;
  double? get drawerEdgeDragWidth;
  bool? get drawerEnableOpenDragGesture;
  bool? get endDrawerEnableOpenDragGesture;

  @override
  ScaffoldBehavior copyWith({
    bool? extendBody,
    bool? extendBodyBehindAppBar,
    PreferredSizeWidget? appBar,
    Widget Function(BuildContext, Widget?)? body,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    FloatingActionButtonAnimator? floatingActionButtonAnimator,
    List<Widget>? persistentFooterButtons,
    AlignmentDirectional? persistentFooterAlignment,
    Widget? drawer,
    void Function(bool)? onDrawerChanged,
    Widget? endDrawer,
    void Function(bool)? onEndDrawerChanged,
    Color? drawerScrimColor,
    Color? backgroundColor,
    Widget? bottomNavigationBar,
    Widget? bottomSheet,
    bool? resizeToAvoidBottomInset,
    bool? primary,
    DragStartBehavior? drawerDragStartBehavior,
    double? drawerEdgeDragWidth,
    bool? drawerEnableOpenDragGesture,
    bool? endDrawerEnableOpenDragGesture,
  }) {
    return ScaffoldBehavior(
      extendBody: extendBody ?? this.extendBody,
      extendBodyBehindAppBar:
          extendBodyBehindAppBar ?? this.extendBodyBehindAppBar,
      appBar: appBar ?? this.appBar,
      body: body ?? this.body,
      floatingActionButton: floatingActionButton ?? this.floatingActionButton,
      floatingActionButtonLocation:
          floatingActionButtonLocation ?? this.floatingActionButtonLocation,
      floatingActionButtonAnimator:
          floatingActionButtonAnimator ?? this.floatingActionButtonAnimator,
      persistentFooterButtons:
          persistentFooterButtons ?? this.persistentFooterButtons,
      persistentFooterAlignment:
          persistentFooterAlignment ?? this.persistentFooterAlignment,
      drawer: drawer ?? this.drawer,
      onDrawerChanged: onDrawerChanged ?? this.onDrawerChanged,
      endDrawer: endDrawer ?? this.endDrawer,
      onEndDrawerChanged: onEndDrawerChanged ?? this.onEndDrawerChanged,
      drawerScrimColor: drawerScrimColor ?? this.drawerScrimColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      bottomNavigationBar: bottomNavigationBar ?? this.bottomNavigationBar,
      bottomSheet: bottomSheet ?? this.bottomSheet,
      resizeToAvoidBottomInset:
          resizeToAvoidBottomInset ?? this.resizeToAvoidBottomInset,
      primary: primary ?? this.primary,
      drawerDragStartBehavior:
          drawerDragStartBehavior ?? this.drawerDragStartBehavior,
      drawerEdgeDragWidth: drawerEdgeDragWidth ?? this.drawerEdgeDragWidth,
      drawerEnableOpenDragGesture:
          drawerEnableOpenDragGesture ?? this.drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture:
          endDrawerEnableOpenDragGesture ?? this.endDrawerEnableOpenDragGesture,
    );
  }

  @override
  ScaffoldBehavior lerp(
      covariant ThemeExtension<ScaffoldBehavior>? other, double t) {
    if (other is! ScaffoldBehavior) return this as ScaffoldBehavior;
    return ScaffoldBehavior(
      extendBody: t < 0.5 ? extendBody : other.extendBody,
      extendBodyBehindAppBar:
          t < 0.5 ? extendBodyBehindAppBar : other.extendBodyBehindAppBar,
      appBar: t < 0.5 ? appBar : other.appBar,
      body: t < 0.5 ? body : other.body,
      floatingActionButton:
          t < 0.5 ? floatingActionButton : other.floatingActionButton,
      floatingActionButtonLocation: t < 0.5
          ? floatingActionButtonLocation
          : other.floatingActionButtonLocation,
      floatingActionButtonAnimator: t < 0.5
          ? floatingActionButtonAnimator
          : other.floatingActionButtonAnimator,
      persistentFooterButtons:
          t < 0.5 ? persistentFooterButtons : other.persistentFooterButtons,
      persistentFooterAlignment:
          t < 0.5 ? persistentFooterAlignment : other.persistentFooterAlignment,
      drawer: t < 0.5 ? drawer : other.drawer,
      onDrawerChanged: t < 0.5 ? onDrawerChanged : other.onDrawerChanged,
      endDrawer: t < 0.5 ? endDrawer : other.endDrawer,
      onEndDrawerChanged:
          t < 0.5 ? onEndDrawerChanged : other.onEndDrawerChanged,
      drawerScrimColor: Color.lerp(drawerScrimColor, other.drawerScrimColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      bottomNavigationBar:
          t < 0.5 ? bottomNavigationBar : other.bottomNavigationBar,
      bottomSheet: t < 0.5 ? bottomSheet : other.bottomSheet,
      resizeToAvoidBottomInset:
          t < 0.5 ? resizeToAvoidBottomInset : other.resizeToAvoidBottomInset,
      primary: t < 0.5 ? primary : other.primary,
      drawerDragStartBehavior:
          t < 0.5 ? drawerDragStartBehavior : other.drawerDragStartBehavior,
      drawerEdgeDragWidth:
          t < 0.5 ? drawerEdgeDragWidth : other.drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: t < 0.5
          ? drawerEnableOpenDragGesture
          : other.drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: t < 0.5
          ? endDrawerEnableOpenDragGesture
          : other.endDrawerEnableOpenDragGesture,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScaffoldBehavior &&
            const DeepCollectionEquality()
                .equals(extendBody, other.extendBody) &&
            const DeepCollectionEquality()
                .equals(extendBodyBehindAppBar, other.extendBodyBehindAppBar) &&
            const DeepCollectionEquality().equals(appBar, other.appBar) &&
            const DeepCollectionEquality().equals(body, other.body) &&
            const DeepCollectionEquality()
                .equals(floatingActionButton, other.floatingActionButton) &&
            const DeepCollectionEquality().equals(floatingActionButtonLocation,
                other.floatingActionButtonLocation) &&
            const DeepCollectionEquality().equals(floatingActionButtonAnimator,
                other.floatingActionButtonAnimator) &&
            const DeepCollectionEquality().equals(
                persistentFooterButtons, other.persistentFooterButtons) &&
            const DeepCollectionEquality().equals(
                persistentFooterAlignment, other.persistentFooterAlignment) &&
            const DeepCollectionEquality().equals(drawer, other.drawer) &&
            const DeepCollectionEquality()
                .equals(onDrawerChanged, other.onDrawerChanged) &&
            const DeepCollectionEquality().equals(endDrawer, other.endDrawer) &&
            const DeepCollectionEquality()
                .equals(onEndDrawerChanged, other.onEndDrawerChanged) &&
            const DeepCollectionEquality()
                .equals(drawerScrimColor, other.drawerScrimColor) &&
            const DeepCollectionEquality()
                .equals(backgroundColor, other.backgroundColor) &&
            const DeepCollectionEquality()
                .equals(bottomNavigationBar, other.bottomNavigationBar) &&
            const DeepCollectionEquality()
                .equals(bottomSheet, other.bottomSheet) &&
            const DeepCollectionEquality().equals(
                resizeToAvoidBottomInset, other.resizeToAvoidBottomInset) &&
            const DeepCollectionEquality().equals(primary, other.primary) &&
            const DeepCollectionEquality().equals(
                drawerDragStartBehavior, other.drawerDragStartBehavior) &&
            const DeepCollectionEquality()
                .equals(drawerEdgeDragWidth, other.drawerEdgeDragWidth) &&
            const DeepCollectionEquality().equals(drawerEnableOpenDragGesture,
                other.drawerEnableOpenDragGesture) &&
            const DeepCollectionEquality().equals(
                endDrawerEnableOpenDragGesture,
                other.endDrawerEnableOpenDragGesture));
  }

  @override
  int get hashCode {
    return Object.hashAll([
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(extendBody),
      const DeepCollectionEquality().hash(extendBodyBehindAppBar),
      const DeepCollectionEquality().hash(appBar),
      const DeepCollectionEquality().hash(body),
      const DeepCollectionEquality().hash(floatingActionButton),
      const DeepCollectionEquality().hash(floatingActionButtonLocation),
      const DeepCollectionEquality().hash(floatingActionButtonAnimator),
      const DeepCollectionEquality().hash(persistentFooterButtons),
      const DeepCollectionEquality().hash(persistentFooterAlignment),
      const DeepCollectionEquality().hash(drawer),
      const DeepCollectionEquality().hash(onDrawerChanged),
      const DeepCollectionEquality().hash(endDrawer),
      const DeepCollectionEquality().hash(onEndDrawerChanged),
      const DeepCollectionEquality().hash(drawerScrimColor),
      const DeepCollectionEquality().hash(backgroundColor),
      const DeepCollectionEquality().hash(bottomNavigationBar),
      const DeepCollectionEquality().hash(bottomSheet),
      const DeepCollectionEquality().hash(resizeToAvoidBottomInset),
      const DeepCollectionEquality().hash(primary),
      const DeepCollectionEquality().hash(drawerDragStartBehavior),
      const DeepCollectionEquality().hash(drawerEdgeDragWidth),
      const DeepCollectionEquality().hash(drawerEnableOpenDragGesture),
      const DeepCollectionEquality().hash(endDrawerEnableOpenDragGesture),
    ]);
  }
}
