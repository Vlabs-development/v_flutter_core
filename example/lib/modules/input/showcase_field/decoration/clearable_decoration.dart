import 'package:entry/entry.dart';
import 'package:example/modules/input/showcase_field/decoration/suffix_decoration.dart';
import 'package:example/modules/input/showcase_field/showcase_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

class ClearableDecoration<T> extends ShowcaseFieldDecorationWidget<T> {
  const ClearableDecoration({
    required this.child,
    this.controller,
    this.onPressed,
    this.requestFous = true,
    super.key,
  });

  final Widget child;
  final bool requestFous;
  final void Function()? onPressed;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context, FormControl<T> control) {
    useStream(control.valueChanges);

    final suffixInvisible = control.isEmpty && (controller?.text.isEmpty ?? true);

    return SuffixDecoration(
      suffix: suffixInvisible
          ? null
          : Entry(
              opacity: 0,
              duration: const Duration(milliseconds: 400),
              child: IconButton(
                focusNode: useFocusNode(skipTraversal: true),
                icon: Icon(
                  Icons.close,
                  color: context.requireExtension<ReactiveTextFieldStyle>().suffixIconColor,
                ),
                onPressed: () {
                  onPressed?.call();
                  controller?.text = '';
                  control.reset();
                  if (requestFous) {
                    control.focus();
                  }
                },
              ),
            ),
      child: child,
    );
  }
}
