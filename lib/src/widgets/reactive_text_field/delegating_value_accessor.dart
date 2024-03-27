import 'package:reactive_forms/reactive_forms.dart';

/// A generic ControlValueAccessor which receives a delegate for both viewToModel and modelToView to be used.
/// Also, it can receive a parent to fall back to in case some of the delegates are missing.
/// Although a delegate function can return null, when that happens the corresponding parent function is returned.
class DelegatingValueAccessor<ModelDataType, ViewDataType> extends ControlValueAccessor<ModelDataType, ViewDataType> {
  DelegatingValueAccessor({
    this.modelToView,
    this.viewToModel,
    this.parent,
  })  : assert(
          parent != null || ((parent == null) && modelToView != null),
          'When parent is null, then modelToView is required.',
        ),
        assert(
          parent != null || ((parent == null) && viewToModel != null),
          'When parent is null, then viewToModel is required.',
        ),
        assert(
          !(modelToView != null && viewToModel != null && parent != null),
          'When both modelToView and viewToModel is defined, then parent must not be defined.',
        );

  ModelDataType? Function(ViewDataType? viewValue)? viewToModel;
  ViewDataType? Function(ModelDataType? modelValue)? modelToView;
  ControlValueAccessor<ModelDataType, ViewDataType>? parent;

  @override
  ViewDataType? modelToViewValue(ModelDataType? modelValue) {
    return modelToView?.call(modelValue) ?? parent?.modelToViewValue(modelValue);
  }

  @override
  ModelDataType? viewToModelValue(ViewDataType? viewValue) {
    return viewToModel?.call(viewValue) ?? parent?.viewToModelValue(viewValue);
  }
}
