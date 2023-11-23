import 'package:flutter/material.dart';

extension CoreBuildContextExtensions on BuildContext {
  T requireExtension<T>() {
    final extension = Theme.of(this).extension<T>();
    if (extension == null) {
      throw Exception('No extension of type $T found');
    }
    return extension;
  }
}
