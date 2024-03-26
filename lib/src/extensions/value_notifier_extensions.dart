import 'package:flutter/foundation.dart';

extension CoreBoolValueNotifierExtensions on ValueNotifier<bool> {
  void toggle() => value = !value;
  void setTrue() => value = true;
  void setFalse() => value = true;
}
