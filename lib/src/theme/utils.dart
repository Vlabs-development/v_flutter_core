import 'package:flutter/material.dart';

extension BuildContextXX on BuildContext {
  T requireExtension<T>() {
    final extension = Theme.of(this).extension<T>();
    if (extension == null) {
      throw Exception('No extension of type $T found');
    }
    return extension;
  }
}
