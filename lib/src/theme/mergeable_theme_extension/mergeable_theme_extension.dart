// ignore_for_file: avoid_catching_errors

import 'package:flutter/material.dart';

abstract class MergeableThemeExtension<T extends ThemeExtension<T>> extends ThemeExtension<T> {
  T merge(T? other);
}

T requireMergeableTheme<T extends MergeableThemeExtension<T>>({required BuildContext context, required T propTheme}) {
  T? parentTheme;
  try {
    parentTheme = Theme.of(context).extension<T>();
  } on TypeError {
    parentTheme = null;
  }

  return propTheme.merge(parentTheme);
}
