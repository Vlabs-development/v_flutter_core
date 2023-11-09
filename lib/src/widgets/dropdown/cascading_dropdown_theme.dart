import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'cascading_dropdown_theme.tailor.dart';

@TailorMixin(themeGetter: ThemeGetter.onThemeData)
class CascadingDropdownTheme extends ThemeExtension<CascadingDropdownTheme> with _$CascadingDropdownThemeTailorMixin {
  const CascadingDropdownTheme({
    required this.disabledColor,
    required this.selectedColor,
    required this.color,
  });

  @override
  final Color disabledColor;
  @override
  final Color selectedColor;
  @override
  final Color color;
}
