import 'package:example/modules/input/showcase_field/showcase_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

/// These orthogonal properties are exclusive because both cannot be achieved at the same time
/// neither with [suffix] nor with [suffixIcon].
enum SuffixDecorationBehavior { alwaysVisible, alignToTop }

class SuffixDecoration<T> extends ShowcaseFieldDecorationWidget<T> {
  const SuffixDecoration({
    required this.child,
    required this.suffix,
    this.behavior = SuffixDecorationBehavior.alwaysVisible,
    super.key,
  });

  final Widget child;
  final Widget? suffix;
  final SuffixDecorationBehavior behavior;

  @override
  Widget build(BuildContext context, FormControl<T> control) {
    switch (behavior) {
      case SuffixDecorationBehavior.alwaysVisible:
        return _SuffixIconDecoration(
          suffix: suffix,
          child: child,
        );
      case SuffixDecorationBehavior.alignToTop:
        return ApplyThemeExtension(
          theme: ReactiveTextFieldStyle(),
          child: _SuffixDecoration(
            suffix: Container(child: suffix),
            child: child,
          ),
        );
    }
  }
}

class _SuffixIconDecoration<T> extends ShowcaseFieldDecorationWidget<T> {
  const _SuffixIconDecoration({
    required this.child,
    required this.suffix,
    super.key,
  });

  final Widget child;
  final Widget? suffix;

  @override
  Widget build(BuildContext context, FormControl<T> control) {
    return ApplyThemeExtension(
      theme: ReactiveTextFieldBehavior(
        suffixIcon: suffix == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  child: suffix,
                ),
              ),
      ),
      child: child,
    );
  }
}

class _SuffixDecoration<T> extends ShowcaseFieldDecorationWidget<T> {
  const _SuffixDecoration({
    required this.child,
    required this.suffix,
    super.key,
  });

  final Widget child;
  final Widget? suffix;

  @override
  Widget build(BuildContext context, FormControl<T> control) {
    return ApplyThemeExtension(
      theme: ReactiveTextFieldBehavior(
        suffix: suffix,
      ),
      child: child,
    );
  }
}
