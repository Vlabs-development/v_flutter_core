import 'package:reactive_forms/reactive_forms.dart';

typedef TypedValidatorFunction<T> = Map<String, dynamic>? Function(
  AbstractControl<T> control,
);

class TypedDelegateValidator<T> extends Validator<T> {
  final TypedValidatorFunction<T> _validator;

  const TypedDelegateValidator(TypedValidatorFunction<T> validator)
      : _validator = validator,
        super();

  @override
  Map<String, dynamic>? validate(AbstractControl<T> control) {
    return _validator(control);
  }
}
