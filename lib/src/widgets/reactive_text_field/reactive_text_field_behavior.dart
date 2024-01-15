// ignore_for_file: annotate_overrides

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';
import 'package:v_flutter_core/src/theme/mergeable_theme_extension/mergeable_theme_extension.dart';

part 'reactive_text_field_behavior.tailor.dart';

@TailorMixinComponent()
class ReactiveTextFieldBehavior extends MergeableThemeExtension<ReactiveTextFieldBehavior>
    with _$ReactiveTextFieldBehaviorTailorMixin {
  ReactiveTextFieldBehavior({
    this.minLines,
    this.maxLines,
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
    this.showErrorTextWhenEmpty,
    this.contentInsertionConfiguration,
    this.dragStartBehavior,
    this.scrollPadding,
    this.maxLength,
    this.autofillHints,
    this.inputFormatters,
    this.maxLengthEnforcement,
    this.scrollPhysics,
    this.smartDashesType,
    this.smartQuotesType,
    this.spellCheckConfiguration,
    this.restorationId,
    this.textCapitalization,
    this.textInputAction,
    this.keyboardType,
    this.magnifierConfiguration,
    this.selectionControls,
    this.undoController,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.onAppPrivateCommand,
    this.contextMenuBuilder,
    this.buildCounter,
    this.controller,
    this.scrollController,
    this.focusNode,
    // InputDecoration
    this.suffixIcon,
    this.errorMaxLines,
    this.error,
    this.helperMaxLines,
    this.counterText,
    this.helperText,
    this.labelText,
    this.counter,
    // this.enabled,
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
  });

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
  final bool? showErrorTextWhenEmpty;
  final int? minLines;
  final int? maxLines;
  final ContentInsertionConfiguration? contentInsertionConfiguration;
  final DragStartBehavior? dragStartBehavior;
  final EdgeInsets? scrollPadding;
  final int? maxLength;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final ScrollPhysics? scrollPhysics;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final String? restorationId;
  final TextCapitalization? textCapitalization;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextMagnifierConfiguration? magnifierConfiguration;
  final TextSelectionControls? selectionControls;
  final UndoHistoryController? undoController;
  final void Function(FormControl<dynamic> control)? onChanged;
  final void Function(FormControl<dynamic> control)? onEditingComplete;
  final void Function(FormControl<dynamic> control)? onSubmitted;
  final void Function(FormControl<dynamic> control)? onTap;
  final void Function(PointerDownEvent)? onTapOutside;
  final void Function(String, Map<String, dynamic>)? onAppPrivateCommand;
  final Widget Function(BuildContext, EditableTextState)? contextMenuBuilder;
  final Widget? Function(BuildContext, {required int currentLength, required bool isFocused, required int? maxLength})?
      buildCounter;

  /// Only use this to read out data, initializing will not work.
  final TextEditingController? controller;
  final ScrollController? scrollController;
  final FocusNode? focusNode;

  // InputDecoration
  final Widget? suffixIcon;
  final int? errorMaxLines;
  final Widget? error;
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

  @override
  ReactiveTextFieldBehavior merge(ReactiveTextFieldBehavior? other) {
    if (other == null) {
      return this;
    }
    return ReactiveTextFieldBehavior(
      autocorrect: autocorrect ?? other.autocorrect,
      autofocus: autofocus ?? other.autofocus,
      canRequestFocus: canRequestFocus ?? other.canRequestFocus,
      enableIMEPersonalizedLearning: enableIMEPersonalizedLearning ?? other.enableIMEPersonalizedLearning,
      enableInteractiveSelection: enableInteractiveSelection ?? other.enableInteractiveSelection,
      enableSuggestions: enableSuggestions ?? other.enableSuggestions,
      expands: expands ?? other.expands,
      obscureText: obscureText ?? other.obscureText,
      readOnly: readOnly ?? other.readOnly,
      scribbleEnabled: scribbleEnabled ?? other.scribbleEnabled,
      dragStartBehavior: dragStartBehavior ?? other.dragStartBehavior,
      scrollPadding: scrollPadding ?? other.scrollPadding,
      textCapitalization: textCapitalization ?? other.textCapitalization,
      // enabled: enabled ?? other.enabled,
      isCollapsed: isCollapsed ?? other.isCollapsed,
      //
      showCursor: showCursor ?? other.showCursor,
      showErrorTextWhenEmpty: showErrorTextWhenEmpty ?? other.showErrorTextWhenEmpty,
      minLines: minLines ?? other.minLines,
      maxLines: maxLines ?? other.maxLines,
      contentInsertionConfiguration: contentInsertionConfiguration ?? other.contentInsertionConfiguration,
      maxLength: maxLength ?? other.maxLength,
      autofillHints: autofillHints ?? other.autofillHints,
      inputFormatters: inputFormatters ?? other.inputFormatters,
      maxLengthEnforcement: maxLengthEnforcement ?? other.maxLengthEnforcement,
      scrollPhysics: scrollPhysics ?? other.scrollPhysics,
      smartDashesType: smartDashesType ?? other.smartDashesType,
      smartQuotesType: smartQuotesType ?? other.smartQuotesType,
      spellCheckConfiguration: spellCheckConfiguration ?? other.spellCheckConfiguration,
      restorationId: restorationId ?? other.restorationId,
      textInputAction: textInputAction ?? other.textInputAction,
      keyboardType: keyboardType ?? other.keyboardType,
      magnifierConfiguration: magnifierConfiguration ?? other.magnifierConfiguration,
      selectionControls: selectionControls ?? other.selectionControls,
      undoController: undoController ?? other.undoController,
      onChanged: mergeHandler(onChanged, other.onChanged),
      onEditingComplete: mergeHandler(onEditingComplete, other.onEditingComplete),
      onSubmitted: mergeHandler(onSubmitted, other.onSubmitted),
      onTap: mergeHandler(onTap, other.onTap),
      onTapOutside: mergeTapOutsideHandler(onTapOutside, other.onTapOutside),
      onAppPrivateCommand: mergeAppPrivateCommandHandler(onAppPrivateCommand, other.onAppPrivateCommand),
      contextMenuBuilder: contextMenuBuilder ?? other.contextMenuBuilder,
      buildCounter: buildCounter ?? other.buildCounter,
      controller: controller ?? other.controller,
      scrollController: scrollController ?? other.scrollController,
      focusNode: focusNode ?? other.focusNode,
      suffixIcon: suffixIcon ?? other.suffixIcon,
      errorMaxLines: errorMaxLines ?? other.errorMaxLines,
      error: error ?? other.error,
      helperMaxLines: helperMaxLines ?? other.helperMaxLines,
      counterText: counterText ?? other.counterText,
      helperText: helperText ?? other.helperText,
      labelText: labelText ?? other.labelText,
      counter: counter ?? other.counter,
      errorText: errorText ?? other.errorText,
      floatingLabelBehavior: floatingLabelBehavior ?? other.floatingLabelBehavior,
      hintMaxLines: hintMaxLines ?? other.hintMaxLines,
      hintText: hintText ?? other.hintText,
      hintTextDirection: hintTextDirection ?? other.hintTextDirection,
      icon: icon ?? other.icon,
      isDense: isDense ?? other.isDense,
      label: label ?? other.label,
      prefix: prefix ?? other.prefix,
      prefixIcon: prefixIcon ?? other.prefixIcon,
      prefixText: prefixText ?? other.prefixText,
      semanticCounterText: semanticCounterText ?? other.semanticCounterText,
      suffix: suffix ?? other.suffix,
      suffixText: suffixText ?? other.suffixText,
    );
  }
}

void Function(FormControl<dynamic>)? mergeHandler(
  void Function(FormControl<dynamic>)? a,
  void Function(FormControl<dynamic>)? b,
) {
  if (a == null && b == null) {
    return null;
  }
  if (a == null) {
    return b;
  }
  if (b == null) {
    return a;
  }
  return (it) {
    a(it);
    b(it);
  };
}

void Function(PointerDownEvent)? mergeTapOutsideHandler(
  void Function(PointerDownEvent)? a,
  void Function(PointerDownEvent)? b,
) {
  if (a == null && b == null) {
    return null;
  }
  if (a == null) {
    return b;
  }
  if (b == null) {
    return a;
  }
  return (it) {
    a(it);
    b(it);
  };
}

void Function(String, Map<String, dynamic>)? mergeAppPrivateCommandHandler(
  void Function(String, Map<String, dynamic>)? a,
  void Function(String, Map<String, dynamic>)? b,
) {
  if (a == null && b == null) {
    return null;
  }
  if (a == null) {
    return b;
  }
  if (b == null) {
    return a;
  }
  return (p1, p2) {
    a(p1, p2);
    b(p1, p2);
  };
}
