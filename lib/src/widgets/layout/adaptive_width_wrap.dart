import 'package:flutter/material.dart';
import 'package:v_flutter_core/src/widgets/layout/adaptive_width_sliver_grid_delegate.dart';

class AdaptiveWidthWrap extends StatelessWidget {
  const AdaptiveWidthWrap({
    required this.children,
    required this.height,
    required this.minWidth,
    required this.maxWidth,
    this.runSpacing = 0,
    this.spacing = 0,
    super.key,
  });

  final List<Widget> children;
  final double height;
  final double minWidth;
  final double maxWidth;
  final double runSpacing;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return GridView.custom(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: AdaptiveWidthSliverGridDelegate(
        height: height,
        minWidth: minWidth,
        maxWidth: maxWidth,
        mainAxisSpacing: spacing,
        crossAxisSpacing: runSpacing,
        itemCount: children.length,
      ),
      childrenDelegate: SliverChildListDelegate(children),
    );
  }
}
