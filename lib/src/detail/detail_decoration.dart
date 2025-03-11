import 'package:flutter/material.dart';
import 'package:simple_gallery/simple_gallery.dart';
import 'package:simple_gallery/src/detail/detail_page_screen.dart';

typedef BackgroundBuilder = Widget? Function(BuildContext context);

class DetailDecoration<T extends Object> {
  final ItemBuilder<T> detailBuilder;

  final PlaceholderBuilder<T>? placeholderBuilder;

  /// Builder for the header widget (e.g., title, close button).
  final DetailActionBuilder<T>? headerBuilder;

  /// Builder for the footer widget (e.g., captions, controls).
  final DetailActionBuilder<T>? footerBuilder;

  /// Gap between items when swiping in the PageView.
  final double pageGap;

  /// Optional background widget for the detail screen.
  final BackgroundBuilder? backgroundBuilder;

  DetailDecoration({
    required this.detailBuilder,
    this.placeholderBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.pageGap = 0.0,
    this.backgroundBuilder,
  });
}
