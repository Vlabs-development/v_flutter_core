// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element, unnecessary_cast

part of 'cascading_dropdown_theme.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$CascadingDropdownThemeTailorMixin
    on ThemeExtension<CascadingDropdownTheme> {
  Color get disabledColor;
  Color get selectedColor;
  Color get color;

  @override
  CascadingDropdownTheme copyWith({
    Color? disabledColor,
    Color? selectedColor,
    Color? color,
  }) {
    return CascadingDropdownTheme(
      disabledColor: disabledColor ?? this.disabledColor,
      selectedColor: selectedColor ?? this.selectedColor,
      color: color ?? this.color,
    );
  }

  @override
  CascadingDropdownTheme lerp(
      covariant ThemeExtension<CascadingDropdownTheme>? other, double t) {
    if (other is! CascadingDropdownTheme) return this as CascadingDropdownTheme;
    return CascadingDropdownTheme(
      disabledColor: Color.lerp(disabledColor, other.disabledColor, t)!,
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t)!,
      color: Color.lerp(color, other.color, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CascadingDropdownTheme &&
            const DeepCollectionEquality()
                .equals(disabledColor, other.disabledColor) &&
            const DeepCollectionEquality()
                .equals(selectedColor, other.selectedColor) &&
            const DeepCollectionEquality().equals(color, other.color));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(disabledColor),
      const DeepCollectionEquality().hash(selectedColor),
      const DeepCollectionEquality().hash(color),
    );
  }
}

extension CascadingDropdownThemeThemeData on ThemeData {
  CascadingDropdownTheme get cascadingDropdownTheme =>
      extension<CascadingDropdownTheme>()!;
}
