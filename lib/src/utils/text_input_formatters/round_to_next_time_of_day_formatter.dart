import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:v_flutter_core/src/extensions/time_of_day_extensions.dart';

class RoundToNextTimeOfDayFormatter extends TextInputFormatter {
  RoundToNextTimeOfDayFormatter({
    required this.availableTimeOfDayValues,
  });

  final List<TimeOfDay> availableTimeOfDayValues;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;

    if (newText.length != 5) {
      return newValue;
    }

    final newTimeOfDay = safeParseTimeOfDay(newText);

    if (newTimeOfDay == null) {
      return newValue;
    }

    if (availableTimeOfDayValues.contains(newTimeOfDay)) {
      return newValue;
    } else {
      final nextTime = availableTimeOfDayValues.firstWhereOrNull((time) => time.isAfter(newTimeOfDay));
      if (nextTime != null) {
        final formattedValue = formatTimeOfDay(nextTime);
        return newValue.copyWith(text: formattedValue);
      } else {
        return newValue.copyWith(text: formatTimeOfDay(availableTimeOfDayValues.last));
      }
    }
  }
}
