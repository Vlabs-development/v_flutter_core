import 'package:reactive_forms/reactive_forms.dart';

/// A generic ControlValueAccessor which receives a delegate for both viewToModel and modelToView to be used.
/// Also, it can receive a parent to fall back to in case some of the delegates are missing.
/// In addition, when [fallbackToParentOnNull] is true (the default) then the parent is used when the delegate returns null.
class DelegatingValueAccessor<ModelDataType, ViewDataType> extends ControlValueAccessor<ModelDataType, ViewDataType> {
  DelegatingValueAccessor({
    this.modelToView,
    this.viewToModel,
    this.parent,
    this.fallbackToParentOnNull = true,
  })  : assert(
          parent != null || ((parent == null) && modelToView != null),
          'When parent is null, then modelToView is required.',
        ),
        assert(
          parent != null || ((parent == null) && viewToModel != null),
          'When parent is null, then viewToModel is required.',
        ),
        assert(
          !(modelToView != null && viewToModel != null && !fallbackToParentOnNull && parent != null),
          'When both modelToView and viewToModel is defined, and fallbackToParentOnNull is false, then parent is not used.',
        );

  ModelDataType? Function(ViewDataType? viewValue)? viewToModel;
  ViewDataType? Function(ModelDataType? modelValue)? modelToView;
  ControlValueAccessor<ModelDataType, ViewDataType>? parent;
  bool fallbackToParentOnNull;

  @override
  ViewDataType? modelToViewValue(ModelDataType? modelValue) {
    if (fallbackToParentOnNull) {
      return modelToView?.call(modelValue) ?? parent?.modelToViewValue(modelValue);
    } else {
      return modelToView?.call(modelValue);
    }
  }

  @override
  ModelDataType? viewToModelValue(ViewDataType? viewValue) {
    if (fallbackToParentOnNull) {
      return viewToModel?.call(viewValue) ?? parent?.viewToModelValue(viewValue);
    } else {
      return viewToModel?.call(viewValue);
    }
  }
}
