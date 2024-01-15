// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:async';

extension CoreFn0Extensions<R> on R Function()? {
  R Function()? when(bool condition) => condition ? this : null;
  R Function()? whenPredicate(bool Function() condition) => condition() ? this : null;
  R Function()? whenNotNull(dynamic arg) => when(arg != null);
  R Function()? hook(Function() hook) => this == null
      ? null
      : () {
          hook();
          return this!.call();
        };

  FutureOr<R> Function(P1)? p1<P1>() => (P1 val) => this?.call() as R;
  FutureOr<R> Function(P1, P2)? p2<P1, P2>() => (P1 arg1, P2 arg2) => this?.call() as R;
}

extension CoreFn1Extensions<R, T1> on R Function(T1)? {
  R Function(T1)? when(bool condition) => condition ? this : null;
  R Function(T1)? whenPredicate(bool Function() condition) => condition() ? this : null;
  R Function(T1)? whenNotNull(dynamic arg) => arg != null ? this : null;
}

extension CoreFn2Extensions<R, T1, T2> on R Function(T1, T2)? {
  R Function(T1, T2)? when(bool condition) => condition ? this : null;
  R Function(T1, T2)? whenPredicate(bool Function() condition) => condition() ? this : null;
  R Function(T1, T2)? whenNotNull(dynamic arg) => arg != null ? this : null;
}

extension CoreFn3Extensions<R, T1, T2, T3> on R Function(T1, T2, T3)? {
  R Function(T1, T2, T3)? when(bool condition) => condition ? this : null;
  R Function(T1, T2, T3)? whenPredicate(bool Function() condition) => condition() ? this : null;
  R Function(T1, T2, T3)? whenNotNull(dynamic arg) => arg != null ? this : null;
}

extension CoreFn4Extensions<R, T1, T2, T3, T4> on R Function(T1, T2, T3, T4)? {
  R Function(T1, T2, T3, T4)? when(bool condition) => condition ? this : null;
  R Function(T1, T2, T3, T4)? whenPredicate(bool Function() condition) => condition() ? this : null;
  R Function(T1, T2, T3, T4)? whenNotNull(dynamic arg) => arg != null ? this : null;
}

extension CoreFn5Extensions<R, T1, T2, T3, T4, T5> on R Function(T1, T2, T3, T4, T5)? {
  R Function(T1, T2, T3, T4, T5)? when(bool condition) => condition ? this : null;
  R Function(T1, T2, T3, T4, T5)? whenPredicate(bool Function() condition) => condition() ? this : null;
  R Function(T1, T2, T3, T4, T5)? whenNotNull(dynamic arg) => arg != null ? this : null;
}
