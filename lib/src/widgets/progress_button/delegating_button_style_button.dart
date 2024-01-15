import 'package:flutter/material.dart';
import 'package:v_flutter_core/src/widgets/progress_button/button_variants.dart';

class DelegatingButtonStyleButton extends ButtonStyleButton {

  const DelegatingButtonStyleButton({
    required super.onPressed,
    required super.child,
    required this.variant,
    super.onLongPress,
    super.key,
    super.onHover,
    super.onFocusChange,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.none,
    super.style,
    super.statesController,
  });
  final ButtonVariant variant;

  @override
  ButtonStyle defaultStyleOf(BuildContext context) => variant.defaultStyleOf(context);

  @override
  ButtonStyle? themeStyleOf(BuildContext context) => variant.themeStyleOf(context);
}
