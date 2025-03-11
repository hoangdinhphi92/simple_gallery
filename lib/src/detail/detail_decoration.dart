import 'package:flutter/material.dart';
import 'package:simple_gallery/simple_gallery.dart';

typedef DetailActionBuilder<T extends Object> = Widget Function(BuildContext context, T item);

class DetailDecoration<T extends Object> {

  /// A function that builds the widget for each detail item.
  final ItemBuilder<T> detailBuilder;

  /// A function that provides a placeholder when the item size is null.
  final PlaceholderBuilder<T>? placeholderBuilder;

  /// Builder for the header widget (e.g., title, close button).
  final DetailActionBuilder<T>? headerBuilder;

  /// Builder for the footer widget (e.g., captions, controls).
  final DetailActionBuilder<T>? footerBuilder;

  /// Gap between items when swiping in the PageView.
  final double pageGap;

  /// Optional background widget for the detail screen.
  final Widget? backgroundWidget;

  DetailDecoration({
    required this.detailBuilder,
    this.placeholderBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.pageGap = 0.0,
    this.backgroundWidget,
  });
}
