import 'package:reactive_forms/reactive_forms.dart';

typedef TypedValidatorFunction<T> = Map<String, dynamic>? Function(
  AbstractControl<T> control,
);

class TypedDelegateValidator<T> extends Validator<T> {

  const TypedDelegateValidator(TypedValidatorFunction<T> validator)
      : _validator = validator,
        super();
  final TypedValidatorFunction<T> _validator;

  @override
  Map<String, dynamic>? validate(AbstractControl<T> control) {
    return _validator(control);
  }
}
