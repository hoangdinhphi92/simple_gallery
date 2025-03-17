import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_gallery/simple_gallery.dart';
import 'package:simple_gallery/src/detail/detail_page_screen.dart';

typedef BackgroundBuilder = Widget? Function(BuildContext context);

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

  /// Optional function for background widget in detail screen.
  final BackgroundBuilder? backgroundBuilder;

  /// System UI overlay style for the detail screen.
  final SystemUiOverlayStyle? systemUiOverlayStyle;

  /// Hide action buttons when tapping on the screen.
  final bool tapToHide;

  DetailDecoration({
    required this.detailBuilder,
    this.placeholderBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.pageGap = 0.0,
    this.backgroundBuilder,
    this.systemUiOverlayStyle,
    this.tapToHide = true,
  });
}
