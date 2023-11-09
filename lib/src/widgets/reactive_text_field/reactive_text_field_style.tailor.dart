// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element, unnecessary_cast

part of 'reactive_text_field_style.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$ReactiveTextFieldStyleTailorMixin
    on ThemeExtension<ReactiveTextFieldStyle> {
  Color? get suffixColor;
  Color? get fillColor;
  Color? get selectionColor;
  TextStyle? get textStyle;
  InputBorder? get border;
  TextStyle? get floatingLabelStyle;
  TextStyle? get labelStyle;
  TextStyle? get helperStyle;
  TextStyle? get errorStyle;
  bool? get cursorOpacityAnimates;
  BoxHeightStyle? get selectionHeightStyle;
  BoxWidthStyle? get selectionWidthStyle;
  Brightness? get keyboardAppearance;
  Clip? get clipBehavior;
  Color? get cursorColor;
  double? get cursorWidth;
  double? get cursorHeight;
  MouseCursor? get mouseCursor;
  Radius? get cursorRadius;
  String? get obscuringCharacter;
  StrutStyle? get strutStyle;
  TextAlign? get textAlign;
  TextAlignVertical? get textAlignVertical;
  TextDirection? get textDirection;
  EdgeInsetsGeometry? get contentPadding;
  BoxConstraints? get suffixIconConstraints;
  bool? get alignLabelWithHint;
  BoxConstraints? get decorationConstraints;
  TextStyle? get counterStyle;
  FloatingLabelAlignment? get floatingLabelAlignment;
  TextStyle? get hintStyle;
  Color? get iconColor;
  Color? get prefixIconColor;
  BoxConstraints? get prefixIconConstraints;
  TextStyle? get prefixStyle;
  Color? get suffixIconColor;
  TextStyle? get suffixStyle;
  bool? get filled;

  @override
  ReactiveTextFieldStyle copyWith({
    Color? suffixColor,
    Color? fillColor,
    Color? selectionColor,
    TextStyle? textStyle,
    InputBorder? border,
    TextStyle? floatingLabelStyle,
    TextStyle? labelStyle,
    TextStyle? helperStyle,
    TextStyle? errorStyle,
    bool? cursorOpacityAnimates,
    BoxHeightStyle? selectionHeightStyle,
    BoxWidthStyle? selectionWidthStyle,
    Brightness? keyboardAppearance,
    Clip? clipBehavior,
    Color? cursorColor,
    double? cursorWidth,
    double? cursorHeight,
    MouseCursor? mouseCursor,
    Radius? cursorRadius,
    String? obscuringCharacter,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextAlignVertical? textAlignVertical,
    TextDirection? textDirection,
    EdgeInsetsGeometry? contentPadding,
    BoxConstraints? suffixIconConstraints,
    bool? alignLabelWithHint,
    BoxConstraints? decorationConstraints,
    TextStyle? counterStyle,
    FloatingLabelAlignment? floatingLabelAlignment,
    TextStyle? hintStyle,
    Color? iconColor,
    Color? prefixIconColor,
    BoxConstraints? prefixIconConstraints,
    TextStyle? prefixStyle,
    Color? suffixIconColor,
    TextStyle? suffixStyle,
    bool? filled,
  }) {
    return ReactiveTextFieldStyle(
      suffixColor: suffixColor ?? this.suffixColor,
      fillColor: fillColor ?? this.fillColor,
      selectionColor: selectionColor ?? this.selectionColor,
      textStyle: textStyle ?? this.textStyle,
      border: border ?? this.border,
      floatingLabelStyle: floatingLabelStyle ?? this.floatingLabelStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      helperStyle: helperStyle ?? this.helperStyle,
      errorStyle: errorStyle ?? this.errorStyle,
      cursorOpacityAnimates:
          cursorOpacityAnimates ?? this.cursorOpacityAnimates,
      selectionHeightStyle: selectionHeightStyle ?? this.selectionHeightStyle,
      selectionWidthStyle: selectionWidthStyle ?? this.selectionWidthStyle,
      keyboardAppearance: keyboardAppearance ?? this.keyboardAppearance,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      cursorHeight: cursorHeight ?? this.cursorHeight,
      mouseCursor: mouseCursor ?? this.mouseCursor,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      obscuringCharacter: obscuringCharacter ?? this.obscuringCharacter,
      strutStyle: strutStyle ?? this.strutStyle,
      textAlign: textAlign ?? this.textAlign,
      textAlignVertical: textAlignVertical ?? this.textAlignVertical,
      textDirection: textDirection ?? this.textDirection,
      contentPadding: contentPadding ?? this.contentPadding,
      suffixIconConstraints:
          suffixIconConstraints ?? this.suffixIconConstraints,
      alignLabelWithHint: alignLabelWithHint ?? this.alignLabelWithHint,
      decorationConstraints:
          decorationConstraints ?? this.decorationConstraints,
      counterStyle: counterStyle ?? this.counterStyle,
      floatingLabelAlignment:
          floatingLabelAlignment ?? this.floatingLabelAlignment,
      hintStyle: hintStyle ?? this.hintStyle,
      iconColor: iconColor ?? this.iconColor,
      prefixIconColor: prefixIconColor ?? this.prefixIconColor,
      prefixIconConstraints:
          prefixIconConstraints ?? this.prefixIconConstraints,
      prefixStyle: prefixStyle ?? this.prefixStyle,
      suffixIconColor: suffixIconColor ?? this.suffixIconColor,
      suffixStyle: suffixStyle ?? this.suffixStyle,
      filled: filled ?? this.filled,
    );
  }

  @override
  ReactiveTextFieldStyle lerp(
      covariant ThemeExtension<ReactiveTextFieldStyle>? other, double t) {
    if (other is! ReactiveTextFieldStyle) return this as ReactiveTextFieldStyle;
    return ReactiveTextFieldStyle(
      suffixColor: Color.lerp(suffixColor, other.suffixColor, t),
      fillColor: Color.lerp(fillColor, other.fillColor, t),
      selectionColor: Color.lerp(selectionColor, other.selectionColor, t),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      border: t < 0.5 ? border : other.border,
      floatingLabelStyle:
          TextStyle.lerp(floatingLabelStyle, other.floatingLabelStyle, t),
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t),
      helperStyle: TextStyle.lerp(helperStyle, other.helperStyle, t),
      errorStyle: TextStyle.lerp(errorStyle, other.errorStyle, t),
      cursorOpacityAnimates:
          t < 0.5 ? cursorOpacityAnimates : other.cursorOpacityAnimates,
      selectionHeightStyle:
          t < 0.5 ? selectionHeightStyle : other.selectionHeightStyle,
      selectionWidthStyle:
          t < 0.5 ? selectionWidthStyle : other.selectionWidthStyle,
      keyboardAppearance:
          t < 0.5 ? keyboardAppearance : other.keyboardAppearance,
      clipBehavior: t < 0.5 ? clipBehavior : other.clipBehavior,
      cursorColor: Color.lerp(cursorColor, other.cursorColor, t),
      cursorWidth: t < 0.5 ? cursorWidth : other.cursorWidth,
      cursorHeight: t < 0.5 ? cursorHeight : other.cursorHeight,
      mouseCursor: t < 0.5 ? mouseCursor : other.mouseCursor,
      cursorRadius: t < 0.5 ? cursorRadius : other.cursorRadius,
      obscuringCharacter:
          t < 0.5 ? obscuringCharacter : other.obscuringCharacter,
      strutStyle: t < 0.5 ? strutStyle : other.strutStyle,
      textAlign: t < 0.5 ? textAlign : other.textAlign,
      textAlignVertical: t < 0.5 ? textAlignVertical : other.textAlignVertical,
      textDirection: t < 0.5 ? textDirection : other.textDirection,
      contentPadding: t < 0.5 ? contentPadding : other.contentPadding,
      suffixIconConstraints:
          t < 0.5 ? suffixIconConstraints : other.suffixIconConstraints,
      alignLabelWithHint:
          t < 0.5 ? alignLabelWithHint : other.alignLabelWithHint,
      decorationConstraints:
          t < 0.5 ? decorationConstraints : other.decorationConstraints,
      counterStyle: TextStyle.lerp(counterStyle, other.counterStyle, t),
      floatingLabelAlignment:
          t < 0.5 ? floatingLabelAlignment : other.floatingLabelAlignment,
      hintStyle: TextStyle.lerp(hintStyle, other.hintStyle, t),
      iconColor: Color.lerp(iconColor, other.iconColor, t),
      prefixIconColor: Color.lerp(prefixIconColor, other.prefixIconColor, t),
      prefixIconConstraints:
          t < 0.5 ? prefixIconConstraints : other.prefixIconConstraints,
      prefixStyle: TextStyle.lerp(prefixStyle, other.prefixStyle, t),
      suffixIconColor: Color.lerp(suffixIconColor, other.suffixIconColor, t),
      suffixStyle: TextStyle.lerp(suffixStyle, other.suffixStyle, t),
      filled: t < 0.5 ? filled : other.filled,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReactiveTextFieldStyle &&
            const DeepCollectionEquality()
                .equals(suffixColor, other.suffixColor) &&
            const DeepCollectionEquality().equals(fillColor, other.fillColor) &&
            const DeepCollectionEquality()
                .equals(selectionColor, other.selectionColor) &&
            const DeepCollectionEquality().equals(textStyle, other.textStyle) &&
            const DeepCollectionEquality().equals(border, other.border) &&
            const DeepCollectionEquality()
                .equals(floatingLabelStyle, other.floatingLabelStyle) &&
            const DeepCollectionEquality()
                .equals(labelStyle, other.labelStyle) &&
            const DeepCollectionEquality()
                .equals(helperStyle, other.helperStyle) &&
            const DeepCollectionEquality()
                .equals(errorStyle, other.errorStyle) &&
            const DeepCollectionEquality()
                .equals(cursorOpacityAnimates, other.cursorOpacityAnimates) &&
            const DeepCollectionEquality()
                .equals(selectionHeightStyle, other.selectionHeightStyle) &&
            const DeepCollectionEquality()
                .equals(selectionWidthStyle, other.selectionWidthStyle) &&
            const DeepCollectionEquality()
                .equals(keyboardAppearance, other.keyboardAppearance) &&
            const DeepCollectionEquality()
                .equals(clipBehavior, other.clipBehavior) &&
            const DeepCollectionEquality()
                .equals(cursorColor, other.cursorColor) &&
            const DeepCollectionEquality()
                .equals(cursorWidth, other.cursorWidth) &&
            const DeepCollectionEquality()
                .equals(cursorHeight, other.cursorHeight) &&
            const DeepCollectionEquality()
                .equals(mouseCursor, other.mouseCursor) &&
            const DeepCollectionEquality()
                .equals(cursorRadius, other.cursorRadius) &&
            const DeepCollectionEquality()
                .equals(obscuringCharacter, other.obscuringCharacter) &&
            const DeepCollectionEquality()
                .equals(strutStyle, other.strutStyle) &&
            const DeepCollectionEquality().equals(textAlign, other.textAlign) &&
            const DeepCollectionEquality()
                .equals(textAlignVertical, other.textAlignVertical) &&
            const DeepCollectionEquality()
                .equals(textDirection, other.textDirection) &&
            const DeepCollectionEquality()
                .equals(contentPadding, other.contentPadding) &&
            const DeepCollectionEquality()
                .equals(suffixIconConstraints, other.suffixIconConstraints) &&
            const DeepCollectionEquality()
                .equals(alignLabelWithHint, other.alignLabelWithHint) &&
            const DeepCollectionEquality()
                .equals(decorationConstraints, other.decorationConstraints) &&
            const DeepCollectionEquality()
                .equals(counterStyle, other.counterStyle) &&
            const DeepCollectionEquality()
                .equals(floatingLabelAlignment, other.floatingLabelAlignment) &&
            const DeepCollectionEquality().equals(hintStyle, other.hintStyle) &&
            const DeepCollectionEquality().equals(iconColor, other.iconColor) &&
            const DeepCollectionEquality()
                .equals(prefixIconColor, other.prefixIconColor) &&
            const DeepCollectionEquality()
                .equals(prefixIconConstraints, other.prefixIconConstraints) &&
            const DeepCollectionEquality()
                .equals(prefixStyle, other.prefixStyle) &&
            const DeepCollectionEquality()
                .equals(suffixIconColor, other.suffixIconColor) &&
            const DeepCollectionEquality()
                .equals(suffixStyle, other.suffixStyle) &&
            const DeepCollectionEquality().equals(filled, other.filled));
  }

  @override
  int get hashCode {
    return Object.hashAll([
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(suffixColor),
      const DeepCollectionEquality().hash(fillColor),
      const DeepCollectionEquality().hash(selectionColor),
      const DeepCollectionEquality().hash(textStyle),
      const DeepCollectionEquality().hash(border),
      const DeepCollectionEquality().hash(floatingLabelStyle),
      const DeepCollectionEquality().hash(labelStyle),
      const DeepCollectionEquality().hash(helperStyle),
      const DeepCollectionEquality().hash(errorStyle),
      const DeepCollectionEquality().hash(cursorOpacityAnimates),
      const DeepCollectionEquality().hash(selectionHeightStyle),
      const DeepCollectionEquality().hash(selectionWidthStyle),
      const DeepCollectionEquality().hash(keyboardAppearance),
      const DeepCollectionEquality().hash(clipBehavior),
      const DeepCollectionEquality().hash(cursorColor),
      const DeepCollectionEquality().hash(cursorWidth),
      const DeepCollectionEquality().hash(cursorHeight),
      const DeepCollectionEquality().hash(mouseCursor),
      const DeepCollectionEquality().hash(cursorRadius),
      const DeepCollectionEquality().hash(obscuringCharacter),
      const DeepCollectionEquality().hash(strutStyle),
      const DeepCollectionEquality().hash(textAlign),
      const DeepCollectionEquality().hash(textAlignVertical),
      const DeepCollectionEquality().hash(textDirection),
      const DeepCollectionEquality().hash(contentPadding),
      const DeepCollectionEquality().hash(suffixIconConstraints),
      const DeepCollectionEquality().hash(alignLabelWithHint),
      const DeepCollectionEquality().hash(decorationConstraints),
      const DeepCollectionEquality().hash(counterStyle),
      const DeepCollectionEquality().hash(floatingLabelAlignment),
      const DeepCollectionEquality().hash(hintStyle),
      const DeepCollectionEquality().hash(iconColor),
      const DeepCollectionEquality().hash(prefixIconColor),
      const DeepCollectionEquality().hash(prefixIconConstraints),
      const DeepCollectionEquality().hash(prefixStyle),
      const DeepCollectionEquality().hash(suffixIconColor),
      const DeepCollectionEquality().hash(suffixStyle),
      const DeepCollectionEquality().hash(filled),
    ]);
  }
}
