import 'dart:math';

import 'package:flutter/material.dart';

extension CoreGlobalKeyExtensions on GlobalKey {
  Size? get maybeSize {
    if (currentContext == null) {
      return null;
    }

    final renderBox = currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return null;
    } else {
      return renderBox.hasSize ? renderBox.size : null;
    }
  }

  Offset? get maybeOffset {
    final renderBox = currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return null;
    } else {
      return renderBox.localToGlobal(Offset.zero);
    }
  }

  Size get size => maybeSize ?? Size.zero;

  Offset get offset => maybeOffset ?? Offset.zero;

  Point get centerPoint {
    if (offset == Offset.zero) {
      return const Point(0, 0);
    }

    final centerX = offset.dx + (size.width / 2);
    final centerY = offset.dy + (size.height / 2);

    return Point(centerX, centerY);
  }

  Alignment getQuadrantAlignment(Size referenceRect) {
    final halfWidth = referenceRect.width / 2;
    final halfHeight = referenceRect.height / 2;

    if (centerPoint.x < halfWidth && centerPoint.y < halfHeight) {
      return Alignment.topLeft;
    } else if (centerPoint.x >= halfWidth && centerPoint.y < halfHeight) {
      return Alignment.topRight;
    } else if (centerPoint.x < halfWidth && centerPoint.y >= halfHeight) {
      return Alignment.bottomLeft;
    } else {
      return Alignment.bottomRight;
    }
  }
}
