import 'package:flutter/material.dart';
import 'package:v_flutter_core/src/theme/mergeable_theme_extension/mergeable_theme_extension.dart';

enum ThemeInterweaveStrategy {
  merge,
  apply,
  override,
}

extension ThemeDataExtensions on ThemeData {
  ThemeData copyWithInterweavedThemeExtension<T extends MergeableThemeExtension<T>>(
    T theme, {
    ThemeInterweaveStrategy strategy = ThemeInterweaveStrategy.merge,
  }) {
    final result = {...extensions};

    result.update(
      T,
      (current) {
        assert(current is T);
        if (current is! T) {
          return theme;
        }

        switch (strategy) {
          case ThemeInterweaveStrategy.merge:
            final merged = current.merge(theme);
            return merged;
          case ThemeInterweaveStrategy.apply:
            final applied = theme.merge(current);
            return applied;
          case ThemeInterweaveStrategy.override:
            return theme;
        }
      },
      ifAbsent: () => theme,
    );

    return copyWith(extensions: result.values);
  }

  ThemeData mergeThemeExtension<T extends MergeableThemeExtension<T>>(T theme) {
    return copyWithInterweavedThemeExtension(theme);
  }

  ThemeData applyThemeExtension<T extends MergeableThemeExtension<T>>(T theme) {
    return copyWithInterweavedThemeExtension(theme, strategy: ThemeInterweaveStrategy.apply);
  }

  ThemeData overrideThemeExtension<T extends MergeableThemeExtension<T>>(T theme) {
    return copyWithInterweavedThemeExtension(theme, strategy: ThemeInterweaveStrategy.override);
  }

  ThemeData copyWithThemeExtension<T extends ThemeExtension<T>>(T theme) {
    final result = {...extensions};
    result[T] = theme;
    return copyWith(extensions: result.values);
  }
}

class OverrideThemeExtension<T extends MergeableThemeExtension<T>> extends StatelessWidget {
  const OverrideThemeExtension({
    required this.child,
    required this.theme,
    super.key,
  });

  final Widget child;
  final T theme;

  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context).overrideThemeExtension(theme),
        child: child,
      );
}

class MergeThemeExtension<T extends MergeableThemeExtension<T>> extends StatelessWidget {
  const MergeThemeExtension({
    required this.child,
    required this.theme,
    super.key,
  });

  final Widget child;
  final T theme;

  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context).mergeThemeExtension(theme),
        child: child,
      );
}

class ApplyThemeExtension<T extends MergeableThemeExtension<T>> extends StatelessWidget {
  const ApplyThemeExtension({
    required this.child,
    required this.theme,
    super.key,
  });

  final Widget child;
  final T theme;

  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context).applyThemeExtension(theme),
        child: child,
      );
}

class AnimatedMergeThemeExtension<T extends MergeableThemeExtension<T>> extends StatelessWidget {
  const AnimatedMergeThemeExtension({
    required this.child,
    required this.theme,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  final Widget child;
  final T theme;

  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) => AnimatedTheme(
        data: Theme.of(context).mergeThemeExtension(theme),
        duration: duration,
        curve: curve,
        child: child,
      );
}

class AnimatedApplyThemeExtension<T extends MergeableThemeExtension<T>> extends StatelessWidget {
  const AnimatedApplyThemeExtension({
    required this.child,
    required this.theme,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  final Widget child;
  final T theme;

  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) => AnimatedTheme(
        data: Theme.of(context).applyThemeExtension(theme),
        duration: duration,
        curve: curve,
        child: child,
      );
}

class AnimatedOverrideThemeExtension<T extends MergeableThemeExtension<T>> extends StatelessWidget {
  const AnimatedOverrideThemeExtension({
    required this.child,
    required this.theme,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  final Widget child;
  final T theme;

  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) => AnimatedTheme(
        data: Theme.of(context).overrideThemeExtension(theme),
        duration: duration,
        curve: curve,
        child: child,
      );
}
