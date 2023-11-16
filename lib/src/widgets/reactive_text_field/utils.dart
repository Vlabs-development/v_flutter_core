import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

bool defaultShowErrors(AbstractControl<dynamic> control) => control.invalid && control.dirty && control.touched;

extension AbstractControlX<T> on AbstractControl<T> {
  bool get isEmpty {
    final tempControl = FormControl<dynamic>(
      value: value,
      validators: [
        Validators.required,
      ],
    );

    final results = tempControl.validators.map(
      (validatorFn) => validatorFn(tempControl),
    );

    return results.any(
      (result) => result != null && result[ValidationMessage.required] == true,
    );
  }

  void markAllAsDirty() {
    if (this is FormGroup) {
      final formGroup = this as FormGroup;
      for (var control in formGroup.controls.values) {
        control.markAllAsDirty();
      }
    } else if (this is FormArray) {
      final formArray = this as FormArray;
      for (var control in formArray.controls) {
        control.markAllAsDirty();
      }
    } else {
      markAsDirty();
    }
  }

  void focusFirstErroneous() {
    if (this is FormGroup) {
      final formGroup = this as FormGroup;
      for (var control in formGroup.controls.values) {
        if (control.invalid) {
          control.focusFirstErroneous();
          return;
        }
      }
    } else if (this is FormArray) {
      final formArray = this as FormArray;
      for (var control in formArray.controls) {
        if (control.invalid) {
          control.focusFirstErroneous();
          return;
        }
      }
    } else {
      if (invalid) {
        focus();
      }
    }
  }
}

extension FormGroupX on FormGroup {
  bool validate({required Function onSuccess}) {
    if (valid) {
      onSuccess();
      return true;
    } else {
      markAllAsTouched();
      markAllAsDirty();
      focusFirstErroneous();
      return false;
    }
  }
}

extension TextEditingControllerX on TextEditingController {
  void triggerValueChanged() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      notifyListeners();
    });
  }

  void setTextWithKeptSelection(String? text) {
    if (text == null) {
      this.text = '';
      return;
    }

    value = TextEditingValue(
      selection: selection.copyWith(
        baseOffset: selection.baseOffset.clamp(0, text.length),
        extentOffset: selection.extentOffset.clamp(0, text.length),
      ),
      text: text,
    );
  }
}
