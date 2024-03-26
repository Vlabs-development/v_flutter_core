import 'dart:math';

import 'package:flutter/material.dart';

extension CoreSizeExtensions on Size {
  Offset keepWithin(Size size, Offset offset) {
    double verticalDelta = 0.0;
    double horizontalDelta = 0.0;

    if (height < offset.dy + size.height) {
      verticalDelta = height - (offset.dy + size.height);
    }

    if (width < offset.dx + size.width) {
      horizontalDelta = width - (offset.dx + size.width);
    }

    return Offset(horizontalDelta, verticalDelta);
  }

  Point relativeCenter(Size size, Offset offset) {
    final heightRatio = size.height / height;
    final heightOffsetRatio = (offset.dy / height) + heightRatio / 2;

    final widthRatio = size.width / width;
    final widthOffsetRatio = (offset.dx / width) + widthRatio / 2;

    return Point(widthOffsetRatio, heightOffsetRatio);
  }
}
