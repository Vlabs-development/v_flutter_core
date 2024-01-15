import 'package:flutter/material.dart';
import 'package:v_flutter_core/src/widgets/type_scale/type_scale_variant.dart';
import 'package:v_flutter_core/src/widgets/type_scale/underline_default_text_style.dart';

class TypeScaleText extends Text {
  const TypeScaleText(
    super.data, {
    super.key,
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
    super.textHeightBehavior,
    super.selectionColor,
    required this.variant,
  });

  final TypeScaleVariant variant;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: variant.resolve(context).merge(style),
      child: Builder(
        builder: (context) {
          final defaultStyle = DefaultTextStyle.of(context).style;

          final hasUnderline = defaultStyle.decoration?.contains(TextDecoration.underline) ?? false;
          final hasStyleColor = style?.color != null;
          assert(!(hasUnderline && hasStyleColor),
              'If underline is specified then color must be null, so the underlined distance can be drawn properly using transparent font and the shadow mimicing the actual text. See: https://stackoverflow.com/a/64839295/4074227.',);

          if (hasUnderline) {
            return UnderlinedFixingDefaultTextStyle(child: Builder(builder: (context) => super.build(context)));
          }

          return Builder(builder: (context) => super.build(context));
        },
      ),
    );
  }
}
