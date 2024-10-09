// ignore_for_file: avoid_catching_errors

import 'package:flutter/material.dart';

extension ThemeExtensionX<T extends ThemeExtension<T>> on ThemeExtension<T> {
  ThemeExtension<T> merge(T? other) => lerp(other, 1);
}

ThemeExtension<T> requireTheme<T extends ThemeExtension<T>>({required BuildContext context, required T propTheme}) {
  T? parentTheme;
  try {
    parentTheme = Theme.of(context).extension<T>();
  } on TypeError {
    parentTheme = null;
  }

  return propTheme.merge(parentTheme);
}
