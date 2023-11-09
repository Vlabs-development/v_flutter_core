import 'package:flutter/material.dart';

abstract class ButtonVariant {
  const ButtonVariant();

  ButtonStyle defaultStyleOf(BuildContext context);
  ButtonStyle? themeStyleOf(BuildContext context);
}

class OutlinedVariant extends ButtonVariant {
  const OutlinedVariant();

  @override
  ButtonStyle defaultStyleOf(BuildContext context) => context.outlinedDefaultStyle(context);
  @override
  ButtonStyle? themeStyleOf(BuildContext context) => context.outlinedThemeStyle(context);
}

class ElevatedVariant extends ButtonVariant {
  const ElevatedVariant();

  @override
  ButtonStyle defaultStyleOf(BuildContext context) => context.elevatedDefaultStyle(context);
  @override
  ButtonStyle? themeStyleOf(BuildContext context) => context.elevatedThemeStyle(context);
}

class TextVariant extends ButtonVariant {
  const TextVariant();

  @override
  ButtonStyle defaultStyleOf(BuildContext context) => context.textDefaultStyle(context);
  @override
  ButtonStyle? themeStyleOf(BuildContext context) => context.textThemeStyle(context);
}

class FilledVariant extends ButtonVariant {
  const FilledVariant();

  @override
  ButtonStyle defaultStyleOf(BuildContext context) => context.filledDefaultStyle(context);
  @override
  ButtonStyle? themeStyleOf(BuildContext context) => context.filledThemeStyle(context);
}

class FilledTonalVariant extends ButtonVariant {
  const FilledTonalVariant();

  @override
  ButtonStyle defaultStyleOf(BuildContext context) => context.filledTonalDefaultStyle(context);
  @override
  ButtonStyle? themeStyleOf(BuildContext context) => context.filledTonalThemeStyle(context);
}

extension BuildContextX on BuildContext {
  static const _elevated = ElevatedButton(onPressed: null, child: Text(''));
  ButtonStyle elevatedDefaultStyle(BuildContext context) => _elevated.defaultStyleOf(context);
  ButtonStyle? elevatedThemeStyle(BuildContext context) => _elevated.themeStyleOf(context);

  static const _outlined = OutlinedButton(onPressed: null, child: Text(''));
  ButtonStyle outlinedDefaultStyle(BuildContext context) => _outlined.defaultStyleOf(context);
  ButtonStyle? outlinedThemeStyle(BuildContext context) => _outlined.themeStyleOf(context);

  static const _text = TextButton(onPressed: null, child: Text(''));
  ButtonStyle textDefaultStyle(BuildContext context) => _text.defaultStyleOf(context);
  ButtonStyle? textThemeStyle(BuildContext context) => _text.themeStyleOf(context);

  static const _filled = FilledButton(onPressed: null, child: Text(''));
  ButtonStyle filledDefaultStyle(BuildContext context) => _filled.defaultStyleOf(context);
  ButtonStyle? filledThemeStyle(BuildContext context) => _filled.themeStyleOf(context);

  static const _filledTonal = FilledButton.tonal(onPressed: null, child: Text(''));
  ButtonStyle filledTonalDefaultStyle(BuildContext context) => _filledTonal.defaultStyleOf(context);
  ButtonStyle? filledTonalThemeStyle(BuildContext context) => _filledTonal.themeStyleOf(context);
}
