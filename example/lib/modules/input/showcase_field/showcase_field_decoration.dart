import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';

final formControlProvider = Provider<FormControl>((ref) {
  throw 'must override';
});

abstract class ShowcaseFieldDecorationWidget<T> extends StatefulWidget {
  const ShowcaseFieldDecorationWidget({super.key});
  Widget build(BuildContext context, FormControl<T> control);

  @override
  ShowcaseFieldDecorationWidgetState<T> createState() => ShowcaseFieldDecorationWidgetState();
}

class ShowcaseFieldDecorationWidgetState<T> extends State<ShowcaseFieldDecorationWidget> {
  @override
  Widget build(BuildContext context) {
    return HookConsumer(
      builder: (context, ref, child) {
        final control = ref.watch(formControlProvider);

        if (control is! FormControl<T>) {
          throw 'FormControlProvider is not of type FormControl<$T>, but ${control.runtimeType}';
        }

        return widget.build(context, control);
      },
    );
  }
}
