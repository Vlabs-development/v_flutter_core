import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_core/src/hooks/use_interval.dart';

class SeamlessCircularProgressIndicator extends HookWidget {
  const SeamlessCircularProgressIndicator({
    super.key,
    this.backgroundColor,
    this.color,
    this.valueColor,
    this.strokeWidth = 4.0,
    this.semanticsLabel,
  });
  final Color? backgroundColor;
  final Color? color;
  final Animation<Color?>? valueColor;
  final double strokeWidth;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final isFillingUp = useState(_getIsFillingUp(DateTime.now()));
    final value = useState(_getCurrentValue(DateTime.now()));

    useInterval(
      () {
        final now = DateTime.now();
        isFillingUp.value = _getIsFillingUp(now);
        value.value = _getCurrentValue(now);
      },
      const Duration(milliseconds: 10),
    );

    return RotationTransition(
      turns: AlwaysStoppedAnimation(isFillingUp.value ? value.value : -value.value),
      child: Transform.scale(
        scaleX: isFillingUp.value ? 1 : -1,
        child: CircularProgressIndicator(
          value: value.value,
          backgroundColor: backgroundColor,
          color: color,
          strokeWidth: strokeWidth,
          semanticsLabel: semanticsLabel,
          valueColor: valueColor,
        ),
      ),
    );
  }

  bool _getIsFillingUp(DateTime dateTime) => dateTime.second.isEven;

  double _getCurrentValue(DateTime dateTime) =>
      _getIsFillingUp(dateTime) ? dateTime.millisecond / 1000 : 1 - (dateTime.millisecond / 1000);
}
