// ignore_for_file: annotate_overrides

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';
import 'package:v_core/src/theme/mergeable_theme_extension/mergeable_theme_extension.dart';

part 'reactive_text_field_style.tailor.dart';

@TailorMixinComponent()
class ReactiveTextFieldStyle extends MergeableThemeExtension<ReactiveTextFieldStyle>
    with _$ReactiveTextFieldStyleTailorMixin {
  ReactiveTextFieldStyle({
    this.suffixColor,
    this.fillColor,
    this.selectionColor,
    this.textStyle,
    this.border,
    this.floatingLabelStyle,
    this.labelStyle,
    this.helperStyle,
    this.errorStyle,
    this.cursorOpacityAnimates,
    this.selectionHeightStyle,
    this.selectionWidthStyle,
    this.keyboardAppearance,
    this.clipBehavior,
    this.cursorColor,
    this.cursorWidth,
    this.cursorHeight,
    this.mouseCursor,
    this.cursorRadius,
    this.obscuringCharacter,
    this.suffixIconConstraints,
    this.strutStyle,
    this.textAlign,
    this.textAlignVertical,
    this.textDirection,
    this.contentPadding,
    this.alignLabelWithHint,
    this.decorationConstraints,
    this.counterStyle,
    this.floatingLabelAlignment,
    this.hintStyle,
    this.iconColor,
    this.prefixIconColor,
    this.prefixIconConstraints,
    this.prefixStyle,
    this.suffixIconColor,
    this.suffixStyle,
    this.filled,
  });
  final Color? suffixColor;
  final Color? fillColor;
  final Color? selectionColor;
  final TextStyle? textStyle;
  final InputBorder? border;
  final TextStyle? floatingLabelStyle;
  final TextStyle? labelStyle;
  final TextStyle? helperStyle;
  final TextStyle? errorStyle;
  final bool? cursorOpacityAnimates;
  final BoxHeightStyle? selectionHeightStyle;
  final BoxWidthStyle? selectionWidthStyle;
  final Brightness? keyboardAppearance;
  final Clip? clipBehavior;
  final Color? cursorColor;
  final double? cursorWidth;
  final double? cursorHeight;
  final MouseCursor? mouseCursor;
  final Radius? cursorRadius;
  final String? obscuringCharacter;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  // InputDecoration
  final EdgeInsetsGeometry? contentPadding;
  final BoxConstraints? suffixIconConstraints;
  final bool? alignLabelWithHint;
  final BoxConstraints? decorationConstraints;
  final TextStyle? counterStyle;
  final FloatingLabelAlignment? floatingLabelAlignment;
  final TextStyle? hintStyle;
  final Color? iconColor;
  final Color? prefixIconColor;
  final BoxConstraints? prefixIconConstraints;
  final TextStyle? prefixStyle;
  final Color? suffixIconColor;
  final TextStyle? suffixStyle;
  final bool? filled;

  @override
  ReactiveTextFieldStyle merge(ReactiveTextFieldStyle? other) {
    if (other == null) {
      return this;
    }
    return ReactiveTextFieldStyle(
      selectionHeightStyle: selectionHeightStyle ?? other.selectionHeightStyle,
      selectionWidthStyle: selectionWidthStyle ?? other.selectionWidthStyle,
      clipBehavior: clipBehavior ?? other.clipBehavior,
      obscuringCharacter: obscuringCharacter ?? other.obscuringCharacter,
      textAlign: textAlign ?? other.textAlign,
      cursorWidth: cursorWidth ?? other.cursorWidth,
      //
      suffixColor: suffixColor ?? other.suffixColor,
      fillColor: fillColor ?? other.fillColor,
      selectionColor: selectionColor ?? other.selectionColor,
      textStyle: _mergeTextStyle(textStyle, other.textStyle),
      border: border ?? other.border,
      floatingLabelStyle: _mergeTextStyle(floatingLabelStyle, other.floatingLabelStyle),
      labelStyle: _mergeTextStyle(labelStyle, other.labelStyle),
      helperStyle: _mergeTextStyle(helperStyle, other.helperStyle),
      errorStyle: _mergeTextStyle(errorStyle, other.errorStyle),
      cursorOpacityAnimates: cursorOpacityAnimates ?? other.cursorOpacityAnimates,
      keyboardAppearance: keyboardAppearance ?? other.keyboardAppearance,
      cursorColor: cursorColor ?? other.cursorColor,
      cursorHeight: cursorHeight ?? other.cursorHeight,
      mouseCursor: mouseCursor ?? other.mouseCursor,
      cursorRadius: cursorRadius ?? other.cursorRadius,
      strutStyle: strutStyle ?? other.strutStyle,
      textAlignVertical: textAlignVertical ?? other.textAlignVertical,
      textDirection: textDirection ?? other.textDirection,
      suffixIconConstraints: suffixIconConstraints ?? other.suffixIconConstraints,
      contentPadding: contentPadding ?? other.contentPadding,
      alignLabelWithHint: alignLabelWithHint ?? other.alignLabelWithHint,
      decorationConstraints: decorationConstraints ?? other.decorationConstraints,
      counterStyle: _mergeTextStyle(counterStyle, other.counterStyle),
      floatingLabelAlignment: floatingLabelAlignment ?? other.floatingLabelAlignment,
      hintStyle: _mergeTextStyle(hintStyle, other.hintStyle),
      iconColor: iconColor ?? other.iconColor,
      prefixIconColor: prefixIconColor ?? other.prefixIconColor,
      prefixIconConstraints: prefixIconConstraints ?? other.prefixIconConstraints,
      prefixStyle: _mergeTextStyle(prefixStyle, other.prefixStyle),
      suffixIconColor: suffixIconColor ?? other.suffixIconColor,
      suffixStyle: _mergeTextStyle(suffixStyle, other.suffixStyle),
      filled: filled ?? other.filled,
    );
  }
}

TextStyle? _mergeTextStyle(TextStyle? a, TextStyle? b) {
  if (a == null && b == null) {
    return null;
  }
  if (a == null) {
    return b;
  }
  if (b == null) {
    return a;
  }
  return b.merge(a);
}
