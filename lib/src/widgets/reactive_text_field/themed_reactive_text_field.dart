import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:reactive_forms_annotations/reactive_forms_annotations.dart';
import 'package:v_flutter_core/src/theme/mergeable_theme_extension/interweave_theme_extension.dart';
import 'package:v_flutter_core/src/widgets/reactive_text_field/reactive_text_field_style.dart';
import 'package:v_flutter_core/src/widgets/reactive_text_field/reactive_text_field_theme.dart';
import 'package:v_flutter_core/src/widgets/reactive_text_field/utils.dart';

class ThemedReactiveTextField<T> extends HookWidget {
  const ThemedReactiveTextField({
    required this.builder,
    this.showErrors = defaultShowErrors,
    this.formControl,
    this.formControlName,
    super.key,
  }) : assert(
          (formControlName != null && formControl == null) || (formControlName == null && formControl != null),
          'Must provide a formControlName or a formControl, but not both at the same time.',
        );

  final ShowErrorsFunction<T> showErrors;
  final String? formControlName;
  final FormControl<T>? formControl;

  final Widget Function(
    BuildContext context,
    FormControl<T> control,
    ShowErrorsFunction<T> showErrors,
  ) builder;

  @override
  Widget build(BuildContext context) {
    final control = () {
      if (formControl != null) {
        return formControl!;
      }

      final form = ReactiveForm.of(context);
      assert(form != null, 'AppTextField: parent form group not found!');
      final formGroup = form! as FormGroup;
      return formGroup.control(formControlName!) as FormControl<T>;
    }();

    ReactiveTextFieldStyle? getAppTextFieldTheme({
      required BuildContext context,
      required bool disabled,
      required bool focused,
      required bool hovered,
      required bool error,
    }) {
      final theme = Theme.of(context).extension<ReactiveTextFieldTheme>();
      if (theme == null) {
        throw Exception('ReactiveTextFieldTheme extension was not found in the theme.');
      }

      if (disabled) {
        return theme.disabled;
      }

      if (error && focused) {
        return theme.focusedError;
      }

      if (error && hovered) {
        return theme.hoveredError;
      }

      if (error) {
        return theme.error;
      }

      if (focused) {
        return theme.focused;
      }

      if (hovered) {
        return theme.hovered;
      }

      return theme.defaultTheme;
    }

    final isFocused = useState(false);
    final isHoveredState = useState(false);
    final isHoveredNotifier = useValueNotifier(false);

    final theme = useMemoized(
      () =>
          getAppTextFieldTheme(
            context: context,
            disabled: control.disabled,
            focused: isFocused.value,
            hovered: isHoveredState.value,
            error: showErrors(control),
          ) ??
          ReactiveTextFieldStyle(),
      [
        control.disabled,
        isFocused.value,
        isHoveredState.value,
        showErrors(control),
      ],
    );

    useStream(control.statusChanged);

    return AnimatedMergeThemeExtension(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutQuint,
      theme: theme,
      child: ExcludeFocus(
        excluding: control.disabled,
        child: AbsorbPointer(
          absorbing: control.disabled,
          child: FocusableActionDetector(
            focusNode: useFocusNode(skipTraversal: true),
            includeFocusSemantics: false,
            onFocusChange: (value) {
              isFocused.value = value;
              if (!value) {
                isHoveredState.value = isHoveredNotifier.value;
              }
            },
            onShowHoverHighlight: (value) {
              isHoveredNotifier.value = value;
              if (!isFocused.value) {
                isHoveredState.value = value;
              }
            },
            child: Builder(builder: (context) => builder(context, control, showErrors)),
          ),
        ),
      ),
    );
  }
}
