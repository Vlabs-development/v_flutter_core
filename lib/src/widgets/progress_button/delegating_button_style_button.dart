import 'package:flutter/material.dart';
import 'package:v_flutter_core/src/widgets/progress_button/button_variants.dart';

class DelegatingButtonStyleButton extends ButtonStyleButton {
  final ButtonVariant variant;

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

  @override
  ButtonStyle defaultStyleOf(BuildContext c) => variant.defaultStyleOf(c);

  @override
  ButtonStyle? themeStyleOf(BuildContext c) => variant.themeStyleOf(c);
}
