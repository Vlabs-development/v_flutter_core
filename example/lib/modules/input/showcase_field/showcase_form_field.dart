import 'package:example/modules/input/showcase_field/showcase_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

Widget _identityDecorationBuilder<T>(Widget field, FormControl<T> control) => field;

class ShowcaseFormField<T extends Object?> extends HookWidget {
  const ShowcaseFormField({
    super.key,
    this.label = '',
    this.helper = '',
    this.hint = '',
    this.validationMessages = const {},
    this.onEditingComplete,
    this.onChanged,
    this.focusNode,
    this.showErrors = defaultShowErrors,
    this.formControl,
    this.formControlName,
    this.valueAccessor,
    this.decorate,
  }) : assert(
          (formControlName != null && formControl == null) || (formControlName == null && formControl != null),
          'Must provide either a formControlName or a formControl, but not both at the same time.',
        );

  final Widget Function(Widget field, FormControl<T> control)? decorate;
  final String label;
  final String helper;
  final String hint;
  final FocusNode? focusNode;
  final FormControl<T>? formControl;
  final String? formControlName;
  final void Function(FormControl<T>)? onEditingComplete;
  final void Function(FormControl<T>)? onChanged;
  final Map<String, String Function(Object)> validationMessages;
  final ShowErrorsFunction<T> showErrors;
  final ControlValueAccessor<T, String>? valueAccessor;

  @override
  Widget build(BuildContext context) {
    assert(
      isDynamic<T>() || isNullableStringType<T>() || valueAccessor != null,
      'When T ($T) is not String, a valueAccessor must be provided',
    );

    final inheritedFocusNode = context.requireExtension<ReactiveTextFieldBehavior>().focusNode;
    final effectiveFocusNode = focusNode ?? inheritedFocusNode ?? useFocusNode();

    final control = () {
      if (formControl != null) {
        return formControl!;
      }

      final form = ReactiveForm.of(context);
      if (form == null) throw 'ShowcaseFormField: ReactiveForm not found!';

      final formGroup = form as FormGroup;
      final inheritedFormControl = formGroup.control(formControlName!) as FormControl<T>;
      return inheritedFormControl;
    }();

    useStream(control.valueChanges);

    return ThemedReactiveTextField<T>(
      formControl: control,
      showErrors: showErrors,
      builder: (context, control, showErrors) {
        return ProviderScope(
          key: ValueKey(control.hashCode),
          overrides: [
            formControlProvider.overrideWithValue(control),
          ],
          child: Builder(
            builder: (context) {
              return HookBuilder(
                builder: (context) {
                  final _decorationBuilder = decorate ?? _identityDecorationBuilder;
                  return _decorationBuilder(
                    ConfigurableReactiveTextField<T>(
                      helperText: helper.isEmpty ? null : helper,
                      hintText: hint.isEmpty ? null : hint,
                      formControl: control,
                      labelText: label.isEmpty ? null : label,
                      focusNode: effectiveFocusNode,
                      valueAccessor: valueAccessor,
                      showErrors: showErrors,
                      onTapOutside: (_) {
                        control.unfocus();
                        if (!control.dirty) {
                          control.markAsUntouched();
                        }
                      },
                      onEditingComplete: onEditingComplete,
                      onChanged: onChanged,
                      validationMessages: validationMessages,
                    ),
                    control,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
