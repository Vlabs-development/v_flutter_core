import 'package:flutter/material.dart';

typedef TEXT = UpperCaseText;

class UpperCaseText extends Text {
  UpperCaseText(
    String text, {
    super.style,
    super.strutStyle,
    super.textAlign,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.overflow,
    super.textScaleFactor,
    super.maxLines,
    super.semanticsLabel,
    super.textWidthBasis,
    super.selectionColor,
    super.textHeightBehavior,
    super.key,
  }) : super(text.toUpperCase());
}
