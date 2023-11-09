// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/foundation.dart';

extension BoolX on bool {
  void when({VoidCallback? t, VoidCallback? f}) {
    if (this) {
      t?.call();
    } else {
      f?.call();
    }
  }

  R maybeMap<R extends Object?>({R Function()? t, R Function()? f, required R Function() orElse}) {
    if (this) {
      if (t != null) {
        return t.call();
      }
      return orElse();
    } else {
      if (f != null) {
        return f.call();
      }
      return orElse();
    }
  }

  R map<R extends Object?>({required R Function() t, required R Function() f}) {
    if (this) {
      return t.call();
    } else {
      return f.call();
    }
  }
}
