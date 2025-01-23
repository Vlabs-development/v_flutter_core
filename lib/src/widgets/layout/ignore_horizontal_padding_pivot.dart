import 'package:flutter/material.dart';
import 'package:v_flutter_core/src/widgets/misc/size_reporter.dart';

typedef ChildWrapper = Widget Function({required Widget child});

/// This widget is aware of its width. In its builder parameter it supplies a `ChildWrapper` function that can be used
/// as any other widget (like `Container(child: ...)`). The widgets which are wrapped in this are ignoring the horizontal
/// paddings that the are imposed on them after the pivot.
/// ```dart
///IgnoreHorizontalPaddingPivot(
///  builder: (context, ignorePadding) {
///    return Padding(
///      padding: const EdgeInsets.only(left: 16, right: 24),
///      child: Column(
///        children: [
///          Header(),
///          Body(),
///          ignorePadding(child: Divider()),
///          Footer(),
///        ],
///      ),
///    );
///  },
///);
///```
class IgnoreHorizontalPaddingPivot extends StatelessWidget {
  const IgnoreHorizontalPaddingPivot({
    required this.builder,
    super.key,
  });

  final Widget Function(BuildContext context, ChildWrapper ignorePadding) builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SizeReporter.builder(
          builder: (parentSize, parentOffset) => builder(
            context,
            ({required child}) => SizeReporter.builder(
              builder: (size, offset) {
                final parentDx = parentOffset?.dx ?? 0;
                final parentWidth = parentSize?.width ?? 0;
                final dx = offset?.dx ?? 0;
                final width = size?.width ?? 0;
                final translation = (parentDx + parentWidth / 2) - (dx + width / 2);

                return IntrinsicHeight(
                  child: OverflowBox(
                    maxWidth: parentSize?.width ?? constraints.maxWidth,
                    child: Transform.translate(
                      offset: Offset(translation, 0),
                      child: child,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
}
