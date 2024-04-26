import 'package:flutter/material.dart';

extension CoreStringExtensions on String {
  List<TextSpan> emphasized({
    required RegExp pattern,
    required TextSpan Function(String value) regular,
    required TextSpan Function(String value) emphasized,
  }) {
    return splitMap<TextSpan>(
      pattern,
      onMatch: emphasized,
      onNonMatch: regular,
    );
  }

  List<T> splitMap<T>(
    RegExp pattern, {
    required T Function(String value) onMatch,
    required T Function(String value) onNonMatch,
  }) {
    if (pattern.pattern.isEmpty || !pattern.hasMatch(this)) {
      return [onNonMatch(this)];
    }
    final matches = pattern.allMatches(this).toList();

    int lastMatchEnd = 0;
    final List<T> children = [];

    for (final match in matches) {
      if (match.start != lastMatchEnd) {
        children.add(onNonMatch(substring(lastMatchEnd, match.start)));
      }

      children.add(onMatch(substring(match.start, match.end)));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd != length) {
      children.add(onNonMatch(substring(lastMatchEnd, length)));
    }

    return children;
  }
}
