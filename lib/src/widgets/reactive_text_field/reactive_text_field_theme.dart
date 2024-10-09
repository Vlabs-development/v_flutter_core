import 'package:flutter/material.dart';
import 'package:v_flutter_core/src/widgets/reactive_text_field/reactive_text_field_style.dart';

class ReactiveTextFieldTheme extends ThemeExtension<ReactiveTextFieldTheme> {
  ReactiveTextFieldTheme({
    this.defaultTheme,
    ReactiveTextFieldStyle? focused,
    ReactiveTextFieldStyle? error,
    ReactiveTextFieldStyle? disabled,
    ReactiveTextFieldStyle? hovered,
    ReactiveTextFieldStyle? focusedError,
    ReactiveTextFieldStyle? hoveredError,
  })  : _focused = focused,
        _error = error,
        _disabled = disabled,
        _hovered = hovered,
        _focusedError = focusedError,
        _hoveredError = hoveredError;

  final ReactiveTextFieldStyle? defaultTheme;
  final ReactiveTextFieldStyle? _focused;
  final ReactiveTextFieldStyle? _error;
  final ReactiveTextFieldStyle? _disabled;
  final ReactiveTextFieldStyle? _hovered;
  final ReactiveTextFieldStyle? _focusedError;
  final ReactiveTextFieldStyle? _hoveredError;

  ReactiveTextFieldStyle? get focused => _focused?.merge(defaultTheme) ?? defaultTheme;
  ReactiveTextFieldStyle? get error => _error?.merge(defaultTheme) ?? defaultTheme;
  ReactiveTextFieldStyle? get disabled => _disabled?.merge(defaultTheme) ?? defaultTheme;
  ReactiveTextFieldStyle? get hovered => _hovered?.merge(defaultTheme) ?? defaultTheme;
  ReactiveTextFieldStyle? get focusedError => _focusedError?.merge(defaultTheme) ?? error;
  ReactiveTextFieldStyle? get hoveredError => _hoveredError?.merge(defaultTheme) ?? error;

  @override
  ReactiveTextFieldTheme copyWith({
    ReactiveTextFieldStyle? defaultTheme,
    ReactiveTextFieldStyle? focused,
    ReactiveTextFieldStyle? error,
    ReactiveTextFieldStyle? disabled,
    ReactiveTextFieldStyle? hovered,
    ReactiveTextFieldStyle? focusedError,
    ReactiveTextFieldStyle? hoveredError,
  }) {
    return ReactiveTextFieldTheme(
      defaultTheme: defaultTheme ?? this.defaultTheme,
      focused: focused ?? this.focused,
      error: error ?? this.error,
      disabled: disabled ?? this.disabled,
      hovered: hovered ?? this.hovered,
      focusedError: focusedError ?? this.focusedError,
      hoveredError: hoveredError ?? this.hoveredError,
    );
  }

  @override
  ReactiveTextFieldTheme lerp(ThemeExtension<ReactiveTextFieldTheme>? other, double t) {
    if (other == null || other is! ReactiveTextFieldTheme) {
      return this;
    }

    return other;
  }
}
