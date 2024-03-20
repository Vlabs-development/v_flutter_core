import 'package:flutter/material.dart';

class DefaultChipThemeData extends StatelessWidget {
  const DefaultChipThemeData({
    required this.child,
    required this.style,
  });
  final Widget child;
  final ChipThemeData style;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(chipTheme: Theme.of(context).chipTheme.merge(style)),
      child: child,
    );
  }
}

extension DefaultChipThemeDataExtension on ChipThemeData {
  ChipThemeData merge(ChipThemeData other) {
    return copyWith(
      backgroundColor: other.backgroundColor,
      brightness: other.brightness,
      checkmarkColor: other.checkmarkColor,
      color: other.color,
      deleteIconColor: other.deleteIconColor,
      disabledColor: other.disabledColor,
      elevation: other.elevation,
      iconTheme: other.iconTheme,
      labelPadding: other.labelPadding,
      labelStyle: other.labelStyle,
      padding: other.padding,
      pressElevation: other.pressElevation,
      secondaryLabelStyle: other.secondaryLabelStyle,
      secondarySelectedColor: other.secondarySelectedColor,
      selectedColor: other.selectedColor,
      selectedShadowColor: other.selectedShadowColor,
      shadowColor: other.shadowColor,
      shape: other.shape,
      showCheckmark: other.showCheckmark,
      side: other.side,
      surfaceTintColor: other.surfaceTintColor,
    );
  }
}
