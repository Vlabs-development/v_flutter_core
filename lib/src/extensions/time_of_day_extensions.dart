import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  bool isBefore(TimeOfDay other, {bool inclusive = false}) {
    if (inclusive) {
      return toMinutes() < other.toMinutes() || isAt(other);
    }

    return toMinutes() < other.toMinutes();
  }

  bool isAfter(TimeOfDay other, {bool inclusive = false}) {
    if (inclusive) {
      return toMinutes() > other.toMinutes() || isAt(other);
    }

    return toMinutes() > other.toMinutes();
  }

  bool isAt(TimeOfDay other) {
    return hour == other.hour && minute == other.minute;
  }

  TimeOfDay add(Duration duration, {bool clamp = false, Duration recoil = const Duration(minutes: 15)}) {
    assert(
      recoil >= const Duration(minutes: 1),
      'Recoil must be at least 1 minute, because highest TimeOfDay value is 23:59',
    );

    if (!clamp) {
      return addDuration(duration);
    }

    final newTime = addDuration(duration);
    if (isBefore(newTime)) {
      return newTime;
    } else {
      return const TimeOfDay(hour: 23, minute: 59).subtract(recoil - const Duration(minutes: 1));
    }
  }

  TimeOfDay subtract(Duration duration, {bool clamp = false}) {
    if (!clamp) {
      return subtractDuration(duration);
    }
    final newTime = subtractDuration(duration);
    if (isAfter(newTime)) {
      return newTime;
    } else {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  TimeOfDay addDuration(Duration duration) {
    final added = toMinutes() + duration.inMinutes;
    final addedHour = added ~/ 60 % 24;
    final addedMinute = added % 60;
    return TimeOfDay(hour: addedHour, minute: addedMinute);
  }

  TimeOfDay subtractDuration(Duration duration) {
    final subtracted = toMinutes() - duration.inMinutes;
    final subtractedHour = (subtracted ~/ 60 % 24 + 24) % 24;
    final subtractedMinute = subtracted % 60;
    return TimeOfDay(hour: subtractedHour, minute: subtractedMinute);
  }

  int compareTo(TimeOfDay other) {
    if (hour != other.hour) {
      return hour.compareTo(other.hour);
    } else {
      return minute.compareTo(other.minute);
    }
  }

  Duration difference(TimeOfDay other) {
    final diff = toMinutes() - other.toMinutes();
    return Duration(minutes: diff.abs());
  }

  int toMinutes() => hour * 60 + minute;

  String get asString {
    return formatTimeOfDay(this);
  }
}

extension NullableTimeOfDayExtension on TimeOfDay? {
  bool isBefore(TimeOfDay? other) {
    if (this == null || other == null) return false;
    return this!.toMinutes() < other.toMinutes();
  }

  bool isAfter(TimeOfDay? other) {
    if (this == null || other == null) return false;
    return this!.toMinutes() > other.toMinutes();
  }

  bool isAt(TimeOfDay? other) {
    if (this == null || other == null) return false;
    return this!.hour == other.hour && this!.minute == other.minute;
  }

  TimeOfDay? add(Duration duration, {bool clamp = false}) {
    if (this == null) return null;
    return this!.add(duration, clamp: clamp);
  }

  TimeOfDay? subtract(Duration duration, {bool clamp = false}) {
    if (this == null) return null;
    return this!.subtract(duration, clamp: clamp);
  }

  int compareTo(TimeOfDay? other) {
    if (this == null || other == null) {
      return this == null ? (other == null ? 0 : -1) : 1;
    }
    return this!.compareTo(other);
  }

  Duration? difference(TimeOfDay? other) {
    if (this == null || other == null) return null;
    final diff = this!.toMinutes() - other.toMinutes();
    return Duration(minutes: diff.abs());
  }

  String? get asString {
    if (this == null) return null;
    return formatTimeOfDay(this!);
  }
}

extension TimeOfDayListExtension on Iterable<TimeOfDay> {
  TimeOfDay? get earliest => isEmpty ? null : reduce((value, element) => value.isBefore(element) ? value : element);

  TimeOfDay? get latest => isEmpty ? null : reduce((value, element) => value.isAfter(element) ? value : element);
}

extension NullableTimeOfDayListExtension on Iterable<TimeOfDay?> {
  TimeOfDay? get earliest => where((time) => time != null).fold<TimeOfDay?>(
        null,
        (TimeOfDay? current, TimeOfDay? next) =>
            current == null || (next != null && next.isBefore(current)) ? next : current,
      );

  TimeOfDay? get latest => where((time) => time != null).fold<TimeOfDay?>(
        null,
        (TimeOfDay? current, TimeOfDay? next) =>
            current == null || (next != null && next.isAfter(current)) ? next : current,
      );
}

TimeOfDay parseTimeOfDay(String timeOfDayString) {
  final timeParts = timeOfDayString.split(':');
  if (timeParts.length != 2) {
    throw const FormatException('Invalid time format');
  }

  final hour = int.tryParse(timeParts[0]);
  final minute = int.tryParse(timeParts[1]);

  if (hour == null || minute == null) {
    throw const FormatException('Invalid time format');
  }

  return TimeOfDay(hour: hour, minute: minute);
}

TimeOfDay? safeParseTimeOfDay(String timeOfDayString) {
  try {
    return parseTimeOfDay(timeOfDayString);
  } catch (e) {
    return null;
  }
}

String formatTimeOfDay(TimeOfDay timeOfDay) {
  return '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
}
