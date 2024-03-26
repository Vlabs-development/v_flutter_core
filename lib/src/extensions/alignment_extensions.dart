import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

String _onlyCornersSupportedException(Alignment aligment) =>
    'Only the four corners are supported, but $aligment is not.';

extension CoreAlignmentExtensions on Alignment {
  Aligned asAligned(TextDirection? direction) {
    if (direction == TextDirection.ltr) {
      return leftAligned;
    }

    if (direction == TextDirection.rtl) {
      return rightAligned;
    }

    return naturalAligned;
  }

  Aligned get naturalAligned {
    if (this == Alignment.topLeft) {
      return const Aligned(
        follower: Alignment.topLeft,
        target: Alignment.bottomLeft,
        shiftToWithinBound: AxisFlag(x: true, y: true),
      );
    }
    if (this == Alignment.topRight) {
      return const Aligned(
        follower: Alignment.topRight,
        target: Alignment.bottomRight,
        shiftToWithinBound: AxisFlag(x: true, y: true),
      );
    }
    if (this == Alignment.bottomLeft) {
      return const Aligned(
        follower: Alignment.bottomLeft,
        target: Alignment.topLeft,
        shiftToWithinBound: AxisFlag(x: true, y: true),
      );
    }
    if (this == Alignment.bottomRight) {
      return const Aligned(
        follower: Alignment.bottomRight,
        target: Alignment.topRight,
        shiftToWithinBound: AxisFlag(x: true, y: true),
      );
    }

    throw _onlyCornersSupportedException;
  }

  Aligned get leftAligned {
    if (this == Alignment.topLeft || this == Alignment.topRight) {
      return const Aligned(
        follower: Alignment.topLeft,
        target: Alignment.bottomLeft,
        shiftToWithinBound: AxisFlag(x: true, y: true),
      );
    }
    if (this == Alignment.bottomLeft || this == Alignment.bottomRight) {
      return const Aligned(
        follower: Alignment.bottomLeft,
        target: Alignment.topLeft,
        shiftToWithinBound: AxisFlag(x: true, y: true),
      );
    }

    throw _onlyCornersSupportedException;
  }

  Aligned get rightAligned {
    if (this == Alignment.topLeft || this == Alignment.topRight) {
      return const Aligned(
        follower: Alignment.topRight,
        target: Alignment.bottomRight,
        shiftToWithinBound: AxisFlag(x: true, y: true),
      );
    }
    if (this == Alignment.bottomLeft || this == Alignment.bottomRight) {
      return const Aligned(
        follower: Alignment.bottomRight,
        target: Alignment.topRight,
        shiftToWithinBound: AxisFlag(x: true, y: true),
      );
    }

    throw _onlyCornersSupportedException;
  }
}
