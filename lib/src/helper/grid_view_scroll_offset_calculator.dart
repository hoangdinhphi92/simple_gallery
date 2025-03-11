import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_gallery/src/helper/scroll_offset_calculator.dart';

class GridViewScrollOffsetCalculator extends ScrollOffsetCalculator {
  final Size viewport;
  final Axis scrollDirection;

  final EdgeInsets padding;
  // Grid layout properties
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  GridViewScrollOffsetCalculator({
    required this.viewport,
    required this.scrollDirection,
    required this.padding,
    required this.crossAxisCount,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.childAspectRatio,
  });

  @override
  double calcScrollOffsetAtIndex(int index) {
    // Ensure index is non-negative
    if (index < 0) return 0.0;

    // Calculate usable extent based on scroll direction
    final double usableCrossAxisExtent = max(
      0.0,
      scrollDirection == Axis.vertical
          ? viewport.width - padding.horizontal
          : viewport.height - padding.vertical,
    );

    final double usableMainAxisExtent = max(
      0.0,
      scrollDirection == Axis.vertical
          ? viewport.height - padding.vertical
          : viewport.width - padding.horizontal,
    );

    // Calculate child dimensions
    final double childCrossAxisExtent =
        (usableCrossAxisExtent - (crossAxisSpacing * (crossAxisCount - 1))) /
        crossAxisCount;

    final double childMainAxisExtent = childCrossAxisExtent / childAspectRatio;
    final double mainAxisStride = childMainAxisExtent + mainAxisSpacing;

    // Calculate the row or column position of the item
    // For vertical grid: index ~/ crossAxisCount gives row number
    // For horizontal grid: index ~/ crossAxisCount gives column number
    final int mainAxisPosition = index ~/ crossAxisCount;

    // Calculate the start position of the item in the main axis
    final double itemStartPosition = mainAxisPosition * mainAxisStride;

    // Calculate the center of the item
    final double itemCenter = itemStartPosition + (childMainAxisExtent / 2);

    // Calculate the center of the viewport
    final double viewportCenter = usableMainAxisExtent / 2;

    // Calculate offset needed to center the item in the viewport
    double offset = itemCenter - viewportCenter;

    // Add the initial padding to the offset
    // For vertical: add top padding
    // For horizontal: add left padding
    offset += scrollDirection == Axis.vertical ? padding.top : padding.left;

    // Ensure we don't scroll past the beginning
    return max(0.0, offset);
  }
}
