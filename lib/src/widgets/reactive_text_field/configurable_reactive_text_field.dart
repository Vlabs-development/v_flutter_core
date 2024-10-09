import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactive_forms_annotations/reactive_forms_annotations.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

class ConfigurableReactiveTextField<T> extends HookConsumerWidget {
  const ConfigurableReactiveTextField({
    super.key,
    this.formControl,
    this.validationMessages = const {},
    this.showErrors,
    this.formControlName,
    this.valueAccessor,
    this.autocorrect,
    this.autofocus,
    this.canRequestFocus,
    this.enableIMEPersonalizedLearning,
    this.enableInteractiveSelection,
    this.enableSuggestions,
    this.expands,
    this.obscureText,
    this.readOnly,
    this.scribbleEnabled,
    this.showCursor,
    this.contentInsertionConfiguration,
    this.dragStartBehavior,
    this.scrollPadding,
    this.focusNode,
    this.maxLength,
    this.maxLines,
    this.minLines,
    this.autofillHints,
    this.inputFormatters,
    this.maxLengthEnforcement,
    this.scrollController,
    this.scrollPhysics,
    this.smartDashesType,
    this.smartQuotesType,
    this.spellCheckConfiguration,
    this.restorationId,
    this.textCapitalization,
    this.controller,
    this.textInputAction,
    this.keyboardType,
    this.magnifierConfiguration,
    this.selectionControls,
    this.style,
    this.undoController,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.onAppPrivateCommand,
    this.contextMenuBuilder,
    this.buildCounter,
    // InputDecoration
    this.suffixIcon,
    this.suffixIconConstraints,
    this.errorMaxLines,
    this.helperMaxLines,
    this.counterText,
    this.helperText,
    this.labelText,
    this.counter,
    // this.enabled = true,
    this.errorText,
    this.floatingLabelBehavior,
    this.hintMaxLines,
    this.hintText,
    this.hintTextDirection,
    this.icon,
    this.isCollapsed,
    this.isDense,
    this.label,
    this.prefix,
    this.prefixIcon,
    this.prefixText,
    this.semanticCounterText,
    this.suffix,
    this.suffixText,
    // -------
    // STYLE
    // -------
    this.suffixColor,
    this.fillColor,
    this.selectionColor,
    this.textStyle,
    this.border,
    this.floatingLabelStyle,
    this.labelStyle,
    this.helperStyle,
    this.errorStyle,
    this.cursorOpacityAnimates,
    this.selectionHeightStyle,
    this.selectionWidthStyle,
    this.keyboardAppearance,
    this.clipBehavior,
    this.cursorColor,
    this.cursorWidth,
    this.cursorHeight,
    this.mouseCursor,
    this.cursorRadius,
    this.obscuringCharacter,
    this.strutStyle,
    this.textAlign,
    this.textAlignVertical,
    this.textDirection,
    // InputDecoration
    this.contentPadding,
    this.alignLabelWithHint,
    this.decorationConstraints,
    this.counterStyle,
    this.floatingLabelAlignment,
    this.hintStyle,
    this.iconColor,
    this.prefixIconColor,
    this.prefixIconConstraints,
    this.prefixStyle,
    this.suffixIconColor,
    this.suffixStyle,
    this.filled,
  });

  final FormControl<T>? formControl;
  final String? formControlName;
  final Map<String, ValidationMessageFunction> validationMessages;
  final ShowErrorsFunction<T>? showErrors;
  final ControlValueAccessor<T, String>? valueAccessor;

  final bool? autocorrect;
  final bool? autofocus;
  final bool? canRequestFocus;
  final bool? enableIMEPersonalizedLearning;
  final bool? enableInteractiveSelection;
  final bool? enableSuggestions;
  final bool? expands;
  final bool? obscureText;
  final bool? readOnly;
  final bool? scribbleEnabled;
  final bool? showCursor;
  final ContentInsertionConfiguration? contentInsertionConfiguration;
  final DragStartBehavior? dragStartBehavior;
  final EdgeInsets? scrollPadding;
  final FocusNode? focusNode;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final String? restorationId;
  final TextCapitalization? textCapitalization;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextMagnifierConfiguration? magnifierConfiguration;
  final TextSelectionControls? selectionControls;
  final TextStyle? style;
  final UndoHistoryController? undoController;
  final void Function(FormControl<T>)? onChanged;
  final void Function(FormControl<T>)? onEditingComplete;
  final void Function(FormControl<T>)? onSubmitted;
  final void Function(FormControl<T>)? onTap;
  final void Function(PointerDownEvent)? onTapOutside;
  final void Function(String, Map<String, dynamic>)? onAppPrivateCommand;
  final Widget Function(BuildContext, EditableTextState)? contextMenuBuilder;
  final Widget? Function(BuildContext, {required int currentLength, required bool isFocused, required int? maxLength})?
      buildCounter;
  // InputDecoration
  final Widget? suffixIcon;
  final BoxConstraints? suffixIconConstraints;
  final int? errorMaxLines;
  final int? helperMaxLines;
  final String? counterText;
  final String? helperText;
  final String? labelText;
  final Widget? counter;
  // final bool enabled;
  final String? errorText;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final int? hintMaxLines;
  final String? hintText;
  final TextDirection? hintTextDirection;
  final Widget? icon;
  final bool? isCollapsed;
  final bool? isDense;
  final Widget? label;
  final Widget? prefix;
  final Widget? prefixIcon;
  final String? prefixText;
  final String? semanticCounterText;
  final Widget? suffix;
  final String? suffixText;

  // -------
  // STYLE
  // -------

  final Color? suffixColor;
  final Color? fillColor;
  final Color? selectionColor;
  final TextStyle? textStyle;
  final InputBorder? border;
  final TextStyle? floatingLabelStyle;
  final TextStyle? labelStyle;
  final TextStyle? helperStyle;
  final TextStyle? errorStyle;
  final bool? cursorOpacityAnimates;
  final ui.BoxHeightStyle? selectionHeightStyle;
  final ui.BoxWidthStyle? selectionWidthStyle;
  final Brightness? keyboardAppearance;
  final Clip? clipBehavior;
  final Color? cursorColor;
  final double? cursorWidth;
  final double? cursorHeight;
  final MouseCursor? mouseCursor;
  final Radius? cursorRadius;
  final String? obscuringCharacter;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  // InputDecoration
  final EdgeInsetsGeometry? contentPadding;
  final bool? alignLabelWithHint;
  final BoxConstraints? decorationConstraints;
  final TextStyle? counterStyle;
  final FloatingLabelAlignment? floatingLabelAlignment;
  final TextStyle? hintStyle;
  final Color? iconColor;
  final Color? prefixIconColor;
  final BoxConstraints? prefixIconConstraints;
  final TextStyle? prefixStyle;
  final Color? suffixIconColor;
  final TextStyle? suffixStyle;
  final bool? filled;

  ReactiveTextFieldStyle get propTheme => ReactiveTextFieldStyle(
        suffixColor: suffixColor,
        filled: filled,
        fillColor: fillColor,
        selectionColor: selectionColor,
        textStyle: textStyle,
        border: border,
        floatingLabelStyle: floatingLabelStyle,
        labelStyle: labelStyle,
        helperStyle: helperStyle,
        errorStyle: errorStyle,
        cursorOpacityAnimates: cursorOpacityAnimates,
        selectionHeightStyle: selectionHeightStyle,
        selectionWidthStyle: selectionWidthStyle,
        keyboardAppearance: keyboardAppearance,
        clipBehavior: clipBehavior,
        cursorColor: cursorColor,
        cursorWidth: cursorWidth,
        cursorHeight: cursorHeight,
        mouseCursor: mouseCursor,
        cursorRadius: cursorRadius,
        obscuringCharacter: obscuringCharacter,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textAlignVertical: textAlignVertical,
        textDirection: textDirection,
        suffixIconConstraints: suffixIconConstraints,
        contentPadding: contentPadding,
        alignLabelWithHint: alignLabelWithHint,
        decorationConstraints: decorationConstraints,
        counterStyle: counterStyle,
        floatingLabelAlignment: floatingLabelAlignment,
        hintStyle: hintStyle,
        iconColor: iconColor,
        prefixIconColor: prefixIconColor,
        prefixIconConstraints: prefixIconConstraints,
        prefixStyle: prefixStyle,
        suffixIconColor: suffixIconColor,
        suffixStyle: suffixStyle,
      );

  ReactiveTextFieldBehavior get propBehavior => ReactiveTextFieldBehavior(
        minLines: minLines,
        maxLines: maxLines,
        autocorrect: autocorrect,
        autofocus: autofocus,
        canRequestFocus: canRequestFocus,
        enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
        enableInteractiveSelection: enableInteractiveSelection,
        enableSuggestions: enableSuggestions,
        expands: expands,
        obscureText: obscureText,
        readOnly: readOnly,
        scribbleEnabled: scribbleEnabled,
        showCursor: showCursor,
        contentInsertionConfiguration: contentInsertionConfiguration,
        dragStartBehavior: dragStartBehavior,
        scrollPadding: scrollPadding,
        maxLength: maxLength,
        autofillHints: autofillHints,
        inputFormatters: inputFormatters,
        maxLengthEnforcement: maxLengthEnforcement,
        scrollPhysics: scrollPhysics,
        smartDashesType: smartDashesType,
        smartQuotesType: smartQuotesType,
        spellCheckConfiguration: spellCheckConfiguration,
        restorationId: restorationId,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        magnifierConfiguration: magnifierConfiguration,
        selectionControls: selectionControls,
        undoController: undoController,
        onChanged: (dynamic control) {
          onChanged?.call(control as FormControl<T>);
        }.when(onChanged != null),
        onEditingComplete: (dynamic control) {
          onEditingComplete?.call(control as FormControl<T>);
        }.when(onEditingComplete != null),
        onSubmitted: (dynamic control) {
          onSubmitted?.call(control as FormControl<T>);
        }.when(onSubmitted != null),
        onTap: (dynamic control) {
          onTap?.call(control as FormControl<T>);
        }.when(onTap != null),
        onTapOutside: onTapOutside,
        onAppPrivateCommand: onAppPrivateCommand,
        contextMenuBuilder: contextMenuBuilder,
        buildCounter: buildCounter,
        controller: controller,
        scrollController: scrollController,
        focusNode: focusNode,
        // InputDecoration
        suffixIcon: suffixIcon,
        errorMaxLines: errorMaxLines,
        helperMaxLines: helperMaxLines,
        counterText: counterText,
        helperText: helperText,
        labelText: labelText,
        counter: counter,
        errorText: errorText,
        floatingLabelBehavior: floatingLabelBehavior,
        hintMaxLines: hintMaxLines,
        hintText: hintText,
        hintTextDirection: hintTextDirection,
        icon: icon,
        isCollapsed: isCollapsed,
        isDense: isDense,
        label: label,
        prefix: prefix,
        prefixIcon: prefixIcon,
        prefixText: prefixText,
        semanticCounterText: semanticCounterText,
        suffix: suffix,
        suffixText: suffixText,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = requireTheme(context: context, propTheme: propTheme);
    final behavior = requireTheme(context: context, propTheme: propBehavior);

    return OverrideThemeExtension(
      theme: theme,
      child: OverrideThemeExtension(
        theme: behavior,
        child: DelegatingReactiveTextField<T>(
          showErrors: showErrors,
          formControl: formControl,
          formControlName: formControlName,
          validationMessages: {...validationMessages},
          valueAccessor: valueAccessor,
        ),
      ),
    );
  }
}
