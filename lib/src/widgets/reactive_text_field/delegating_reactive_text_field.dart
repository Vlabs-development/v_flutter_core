import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms_annotations/reactive_forms_annotations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:v_core/v_core.dart';

class DelegatingReactiveTextField<T> extends HookConsumerWidget {
  const DelegatingReactiveTextField({
    super.key,
    this.formControl,
    this.validationMessages = const {},
    this.showErrors,
    this.formControlName,
    this.valueAccessor,
  });

  final FormControl<T>? formControl;
  final String? formControlName;
  final Map<String, ValidationMessageFunction> validationMessages;
  final ShowErrorsFunction<T>? showErrors;
  final ControlValueAccessor<T, String>? valueAccessor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.requireExtension<ReactiveTextFieldStyle>();
    final behavior = context.requireExtension<ReactiveTextFieldBehavior>();

    final control = () {
      if (formControl != null) {
        return formControl!;
      }

      final form = ReactiveForm.of(context);
      assert(form != null, 'AppTextField: parent form group not found!');
      final formGroup = form! as FormGroup;
      return formGroup.control(formControlName!) as FormControl<T>;
    }();

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: Theme.of(context).textSelectionTheme.copyWith(
              cursorColor: theme.textStyle?.color,
              selectionColor: theme.selectionColor,
            ),
      ),
      child: ReactiveTextField<T>(
        showErrors: showErrors,
        formControl: formControl,
        validationMessages: {...validationMessages},
        formControlName: formControlName,
        valueAccessor: valueAccessor,
        autocorrect: behavior.autocorrect ?? true,
        autofillHints: behavior.autofillHints,
        autofocus: behavior.autofocus ?? false,
        buildCounter: behavior.buildCounter,
        canRequestFocus: behavior.canRequestFocus ?? true,
        clipBehavior: theme.clipBehavior ?? Clip.hardEdge,
        contentInsertionConfiguration: behavior.contentInsertionConfiguration,
        contextMenuBuilder: behavior.contextMenuBuilder,
        controller: behavior.controller,
        cursorColor: theme.cursorColor,
        cursorHeight: theme.cursorHeight,
        cursorOpacityAnimates: theme.cursorOpacityAnimates,
        cursorRadius: theme.cursorRadius,
        cursorWidth: theme.cursorWidth ?? 2.0,
        dragStartBehavior: behavior.dragStartBehavior ?? DragStartBehavior.start,
        enableIMEPersonalizedLearning: behavior.enableIMEPersonalizedLearning ?? true,
        enableInteractiveSelection: behavior.enableInteractiveSelection ?? true,
        enableSuggestions: behavior.enableSuggestions ?? true,
        expands: behavior.expands ?? false,
        focusNode: behavior.focusNode,
        inputFormatters: behavior.inputFormatters,
        keyboardAppearance: theme.keyboardAppearance,
        keyboardType: behavior.keyboardType,
        magnifierConfiguration: behavior.magnifierConfiguration,
        maxLength: behavior.maxLength,
        maxLengthEnforcement: behavior.maxLengthEnforcement,
        maxLines: behavior.maxLines ?? 1,
        minLines: behavior.minLines,
        mouseCursor: theme.mouseCursor,
        obscureText: behavior.obscureText ?? false,
        obscuringCharacter: theme.obscuringCharacter ?? '•',
        onAppPrivateCommand: behavior.onAppPrivateCommand,
        onChanged: behavior.onChanged,
        onEditingComplete: behavior.onEditingComplete,
        onSubmitted: behavior.onSubmitted,
        onTap: behavior.onTap,
        onTapOutside: behavior.onTapOutside,
        readOnly: behavior.readOnly ?? false,
        restorationId: behavior.restorationId,
        scribbleEnabled: behavior.scribbleEnabled ?? true,
        scrollController: behavior.scrollController,
        scrollPadding: behavior.scrollPadding ?? const EdgeInsets.all(20.0),
        scrollPhysics: behavior.scrollPhysics,
        selectionControls: behavior.selectionControls,
        selectionHeightStyle: theme.selectionHeightStyle ?? BoxHeightStyle.tight,
        selectionWidthStyle: theme.selectionWidthStyle ?? BoxWidthStyle.tight,
        showCursor: behavior.showCursor,
        smartDashesType: behavior.smartDashesType,
        smartQuotesType: behavior.smartQuotesType,
        spellCheckConfiguration: behavior.spellCheckConfiguration,
        strutStyle: theme.strutStyle,
        style: theme.textStyle,
        textAlign: theme.textAlign ?? TextAlign.start,
        textAlignVertical: theme.textAlignVertical,
        textCapitalization: behavior.textCapitalization ?? TextCapitalization.none,
        textDirection: theme.textDirection,
        textInputAction: behavior.textInputAction,
        undoController: behavior.undoController,
        decoration: InputDecoration(
          alignLabelWithHint: theme.alignLabelWithHint,
          border: theme.border,
          constraints: theme.decorationConstraints,
          contentPadding: theme.contentPadding,
          counter: behavior.counter,
          counterStyle: theme.counterStyle,
          counterText: behavior.counterText,
          disabledBorder: theme.border,
          enabled: control.enabled,
          enabledBorder: theme.border,
          errorBorder: theme.border,
          errorMaxLines: behavior.errorMaxLines,
          errorStyle: theme.errorStyle,
          errorText: behavior.errorText,
          fillColor: theme.fillColor,
          filled: theme.filled,
          floatingLabelAlignment: theme.floatingLabelAlignment,
          floatingLabelBehavior: behavior.floatingLabelBehavior,
          floatingLabelStyle: theme.floatingLabelStyle,
          focusColor: theme.fillColor,
          focusedBorder: theme.border,
          focusedErrorBorder: theme.border,
          helperMaxLines: behavior.helperMaxLines,
          helperStyle: theme.helperStyle,
          helperText: behavior.helperText,
          hintMaxLines: behavior.hintMaxLines,
          hintStyle: theme.hintStyle,
          hintText: behavior.hintText,
          hintTextDirection: behavior.hintTextDirection,
          // Intentionally set to transparent to workaround this bug:
          // https://github.com/flutter/flutter/issues/132373
          hoverColor: Colors.transparent,
          icon: behavior.icon,
          iconColor: theme.iconColor,
          isCollapsed: behavior.isCollapsed ?? false,
          isDense: behavior.isDense,
          label: behavior.label,
          labelStyle: theme.labelStyle,
          labelText: behavior.labelText,
          prefix: behavior.prefix.wrap(
            (child) => IconTheme(
              data: IconThemeData(color: theme.prefixIconColor),
              child: DefaultTextStyle.merge(style: theme.prefixStyle, child: child),
            ),
          ),
          prefixIcon: behavior.prefixIcon,
          prefixIconColor: theme.prefixIconColor,
          prefixIconConstraints: theme.prefixIconConstraints,
          prefixStyle: theme.prefixStyle,
          prefixText: behavior.prefixText,
          semanticCounterText: behavior.semanticCounterText,
          suffix: behavior.suffix.wrap(
            (child) => IconTheme(
              data: IconThemeData(color: theme.suffixIconColor),
              child: DefaultTextStyle.merge(style: theme.suffixStyle, child: child),
            ),
          ),
          suffixIcon: behavior.suffixIcon,
          suffixIconColor: theme.suffixIconColor,
          suffixIconConstraints: theme.suffixIconConstraints,
          suffixStyle: theme.suffixStyle,
          suffixText: behavior.suffixText,
        ),
      ),
    );
  }
}

extension on Widget? {
  Widget? wrap(Widget Function(Widget child) wrapper) {
    if (this == null) {
      return null;
    }

    return wrapper(Container(child: this));
  }
}
