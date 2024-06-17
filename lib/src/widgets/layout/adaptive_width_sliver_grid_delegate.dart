import 'package:flutter/rendering.dart';

class AdaptiveWidthSliverGridDelegate extends SliverGridDelegate {

  AdaptiveWidthSliverGridDelegate({
    required this.height,
    required this.minWidth,
    required this.maxWidth,
    required this.itemCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
  });
  final double height;
  final double minWidth;
  final double maxWidth;
  final int itemCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double availableWidth = constraints.crossAxisExtent;

    int columnCount;
    double itemWidth;

    // Determine the appropriate column count and item width
    if (itemCount * maxWidth + (itemCount - 1) * crossAxisSpacing <= availableWidth) {
      // All items fit in one row with maxWidth
      columnCount = itemCount;
      itemWidth = ((availableWidth - (columnCount - 1) * crossAxisSpacing) / columnCount).clamp(minWidth, maxWidth);
    } else if (itemCount * minWidth + (itemCount - 1) * crossAxisSpacing <= availableWidth) {
      // All items fit in one row with minWidth
      columnCount = itemCount;
      itemWidth = ((availableWidth - (columnCount - 1) * crossAxisSpacing) / columnCount).clamp(minWidth, maxWidth);
    } else {
      // Items need to be split into multiple rows
      columnCount = ((availableWidth + crossAxisSpacing) / (minWidth + crossAxisSpacing)).floor();
      itemWidth = ((availableWidth - (columnCount - 1) * crossAxisSpacing) / columnCount).clamp(minWidth, maxWidth);
    }

    return SliverGridRegularTileLayout(
      crossAxisCount: columnCount,
      mainAxisStride: height + mainAxisSpacing,
      crossAxisStride: itemWidth + crossAxisSpacing,
      childMainAxisExtent: height,
      childCrossAxisExtent: itemWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(AdaptiveWidthSliverGridDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.minWidth != minWidth ||
        oldDelegate.maxWidth != maxWidth ||
        oldDelegate.itemCount != itemCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing;
  }
}
