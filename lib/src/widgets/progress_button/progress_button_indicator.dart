import 'package:flutter/material.dart';
import 'dart:math';

import 'package:v_flutter_core/src/widgets/size_reporter.dart';

class ProgressButtonIndicator extends StatelessWidget {
  const ProgressButtonIndicator({
    required this.child,
    required this.statesController,
    required this.circular,
    required this.resolve,
    this.strokeWidth = 2,
    super.key,
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
