import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/src/widgets/misc/size_reporter.dart';
import 'package:v_flutter_core/src/widgets/progress_button/button_variants.dart';
import 'package:v_flutter_core/src/widgets/progress_button/delegating_button_style_button.dart';

class ProgressButton extends HookWidget {
  const ProgressButton.variant({
    super.key,
    required this.onPressed,
    required this.variant,
    this.isLoading = false,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.circular = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    required this.child,
  });

  const ProgressButton.elevated({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.circular = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    required this.child,
  }) : variant = const ElevatedVariant();

  const ProgressButton.text({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.circular = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    required this.child,
  }) : variant = const TextVariant();

  const ProgressButton.outlined({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.circular = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    required this.child,
  }) : variant = const OutlinedVariant();

  const ProgressButton.filled({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.circular = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    required this.child,
  }) : variant = const FilledVariant();

  const ProgressButton.filledTonal({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.circular = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    required this.child,
  }) : variant = const FilledTonalVariant();
  
  final bool isLoading;
  final ButtonVariant variant;

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final ButtonStyle? style;
  final Clip clipBehavior;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool circular;
  final MaterialStatesController? statesController;

  @override
  Widget build(BuildContext context) {
    final effectiveStatesController = useMemoized(
      () => statesController ?? MaterialStatesController(),
      [statesController],
    );
    final ButtonStyle? themeStyle = variant.themeStyleOf(context);
    final ButtonStyle defaultStyle = variant.defaultStyleOf(context);

    T? pureValue<T>(T? Function(ButtonStyle? style) getProperty) {
      final T? widgetValue = getProperty(style);
      final T? themeValue = getProperty(themeStyle);
      final T? defaultValue = getProperty(defaultStyle);
      return widgetValue ?? themeValue ?? defaultValue;
    }

    T? resolvePure<T>(MaterialStateProperty<T>? Function(ButtonStyle? style) getProperty) {
      return pureValue((ButtonStyle? style) => getProperty(style)?.resolve(effectiveStatesController.value));
    }

    final isCircular = useMemoized(() => child is Icon || circular, [child, circular]);

    final effectiveWidgetStyle = useMemoized(
      () {
        final side = (isLoading && isCircular)
            ? const MaterialStatePropertyAll(BorderSide(color: Colors.transparent, width: 0))
            : null;

        final defaultStyle = (style ?? const ButtonStyle()).copyWith(
          // https://github.com/flutter/flutter/issues/123528
          visualDensity: VisualDensity.standard,
          enableFeedback: !isLoading,
          overlayColor: isLoading ? const MaterialStatePropertyAll(Colors.transparent) : null,
          mouseCursor: isLoading ? const MaterialStatePropertyAll(SystemMouseCursors.basic) : null,
          side: side,
          elevation: isLoading
              // This is not the style's default elevation, but 1 hardcoded
              ? MaterialStateProperty.resolveWith((state) => state.contains(MaterialState.hovered) ? 1 : null)
              : null,
        );

        if (isCircular) {
          if (isLoading) {
            return defaultStyle.copyWith(
              padding: const MaterialStatePropertyAll(EdgeInsets.zero),
              shape: const MaterialStatePropertyAll(CircleBorder()),
            );
          } else {
            return defaultStyle.copyWith(
              shape: const MaterialStatePropertyAll(CircleBorder()),
              padding: MaterialStatePropertyAll(resolvePure((style) => style?.padding)?.chiselCircular),
            );
          }
        }
        return defaultStyle;
      },
      [style, child, isLoading, isCircular],
    );

    T? effectiveValue<T>(T? Function(ButtonStyle? style) getProperty) {
      final T? widgetValue = getProperty(effectiveWidgetStyle);
      final T? themeValue = getProperty(themeStyle);
      final T? defaultValue = getProperty(defaultStyle);
      return widgetValue ?? themeValue ?? defaultValue;
    }

    T? resolveEffective<T>(MaterialStateProperty<T>? Function(ButtonStyle? style) getProperty) {
      return effectiveValue((ButtonStyle? style) => getProperty(style)?.resolve(effectiveStatesController.value));
    }

    return DelegatingButtonStyleButton(
      variant: variant,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      key: key,
      onFocusChange: onFocusChange,
      onHover: onHover,
      style: effectiveWidgetStyle,
      statesController: statesController,
      onPressed: isLoading
          ? onPressed == null
              ? null
              : () {}
          : onPressed,
      onLongPress: isLoading
          ? onLongPress == null
              ? null
              : () {}
          : onLongPress,
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeOutQuad,
        switchOutCurve: Curves.easeInQuad,
        duration: const Duration(milliseconds: 400),
        child: isLoading
            ? ProgressButtonIndicator(
                circular: circular,
                statesController: effectiveStatesController,
                resolve: resolveEffective,
                child: Container(
                  padding: circular ? style?.padding?.resolve({})?.chiselCircular : EdgeInsets.zero,
                  child: child,
                ),
              )
            : child,
      ),
    );
  }
}

extension on EdgeInsetsGeometry {
  EdgeInsets get chiselCircular {
    final minimum = min(horizontal, vertical);
    return EdgeInsets.symmetric(horizontal: minimum / 2, vertical: minimum / 2);
  }
}

class ProgressButtonIndicator extends StatelessWidget {
  const ProgressButtonIndicator({
    super.key,
    required this.child,
    required this.statesController,
    required this.circular,
    required this.resolve,
    this.strokeWidth = 2,
  });

  final double strokeWidth;
  final Widget child;
  final MaterialStatesController statesController;
  final bool circular;
  final T? Function<T>(MaterialStateProperty<T>? Function(ButtonStyle?) getProperty) resolve;

  @override
  Widget build(BuildContext context) {
    return SizedBy(
      anchor: child,
      builder: (size) {
        return Builder(
          builder: (context) {
            final Size? minSize = resolve<Size?>((ButtonStyle? style) => style?.minimumSize);
            final Color? foregroundColor = resolve<Color?>((ButtonStyle? style) => style?.foregroundColor);

            if (child is Icon || circular) {
              return IconTheme(
                data: IconTheme.of(context).copyWith(color: foregroundColor),
                child: SizedBox(
                  width: max(minSize?.width ?? 0, size.width),
                  height: max(minSize?.height ?? 0, size.height),
                  child: Container(
                    margin: EdgeInsets.all(strokeWidth / 2),
                    child: CircularProgressIndicator(
                      color: foregroundColor,
                      strokeWidth: strokeWidth,
                    ),
                  ),
                ),
              );
            } else {
              final progressSize = min(
                max(size.width, 0).toDouble(),
                max(size.height, 0).toDouble(),
              );

              return Positioned.fill(
                child: Center(
                  child: SizedBox(
                    width: progressSize,
                    height: progressSize,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: foregroundColor,
                        strokeWidth: strokeWidth,
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
