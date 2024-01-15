import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class UnderlinedDefaultTextStyle extends StatelessWidget {
  const UnderlinedDefaultTextStyle({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;

    final height = style.height ?? 1.0;
    final fontSize = style.fontSize ?? 16.0;

    final offset = (((1 - height) * fontSize).ceil().toDouble() / 2) - 1;
    final color = style.color ?? Theme.of(context).colorScheme.onSurface;

    return Transform.translate(
      offset: Offset(0, offset * -1),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: Colors.transparent,
          shadows: [Shadow(color: color, offset: Offset(0, offset))],
          decoration: maybeCombine([style.decoration, TextDecoration.underline]),
          decorationColor: color,
          decorationThickness: style.decorationThickness,
        ),
        child: Builder(builder: (context) => child),
      ),
    );
  }
}

class UnderlinedFixingDefaultTextStyle extends StatelessWidget {
  const UnderlinedFixingDefaultTextStyle({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;

    if (style.decoration?.contains(TextDecoration.underline) ?? false) {
      return UnderlinedDefaultTextStyle(child: child);
    }

    return child;
  }
}

TextDecoration? maybeCombine(List<TextDecoration?> decorations) {
  if (decorations.isEmpty) {
    return null;
  }
  final notNullDecorations = decorations.whereNotNull().toList();
  if (notNullDecorations.isEmpty) {
    return null;
  }

  return TextDecoration.combine(notNullDecorations);
}
