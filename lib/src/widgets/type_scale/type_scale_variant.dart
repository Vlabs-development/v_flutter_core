import 'package:flutter/widgets.dart';

abstract class TypeScaleVariant {
  const TypeScaleVariant();

  TextStyle resolve(BuildContext context) => const TextStyle();
}
