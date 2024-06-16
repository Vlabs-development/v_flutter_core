import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/src/widgets/size_reporter.dart';

class SizeOverlay extends HookWidget {
  const SizeOverlay({
    required this.child,
    this.color,
    this.style,
    super.key,
  });

  final Widget child;
  final Color? color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final _size = useState(Size.zero);

    if (!kDebugMode) {
      return child;
    }

    return SizeReporter(
      onChange: (size, offset) => _size.value = size,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: Placeholder(color: color ?? Colors.pink, strokeWidth: 1),
          ),
          Positioned.fill(
            child: Center(
              child: Text(
                '${_formatDouble(_size.value.width)} × ${_formatDouble(_size.value.height)}',
                style: style ?? const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDouble(double number) {
  String formattedNumber = number.toStringAsFixed(2);

  if (formattedNumber.endsWith('.00')) {
    formattedNumber = formattedNumber.substring(0, formattedNumber.length - 3);
  } else if (formattedNumber.endsWith('0')) {
    formattedNumber = formattedNumber.substring(0, formattedNumber.length - 1);
  }

  return formattedNumber;
}
