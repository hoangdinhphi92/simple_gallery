import 'package:flutter/material.dart';
import 'package:simple_gallery/src/detail/detail_decoration.dart';
import 'package:simple_gallery/src/detail/detail_page_screen.dart';
import 'package:simple_gallery/src/gallery/simple_item.dart';

/// ItemBuilder is a function that builds a widget for the given item.
typedef PlaceholderBuilder<T extends Object> = Widget Function(BuildContext context, T item);

/// ItemBuilder is a function that builds a widget for the given item.
typedef ItemBuilder<T extends Object> =
    Widget Function(BuildContext context, T item, Size itemSize, Size viewSize);

/// ItemSize is a function that returns the size of the given item.
typedef ItemSize<T extends Object> = Future<Size> Function(T item);

class SimpleGallery<T extends Object> extends StatefulWidget {

  /// A list of items to be displayed in the gallery.
  final List<T> items;

  /// [itemSize] is a function that returns the size of the given item.
  final ItemSize<T> itemSize;

  /// ItemBuilder is a function that builds a widget for the given item.
  final ItemBuilder<T> itemBuilder;

  /// [placeholderBuilder] will be called only when the size of item is null
  final PlaceholderBuilder<T>? placeholderBuilder;

  /// The number of children in the cross axis. Default is 3.
  final int crossAxisCount;

  /// The number of logical pixels between each child along the cross axis.
  /// Default is 4.0.
  final double crossAxisSpacing;

  /// The number of logical pixels between each child along the main axis.
  /// Default is 4.0.
  final double mainAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  /// Default is 1.0.
  final double childAspectRatio;

  /// The amount of space by which to inset the children.
  /// Default is EdgeInsets.all(4.0).
  final EdgeInsets padding;

  /// Detail decoration properties
  /// Specifies additional styling or decorations for item details.
  final DetailDecoration<T>? detailDecoration;

  const SimpleGallery({
    super.key,
    required this.items,
    required this.itemSize,
    required this.itemBuilder,
    this.placeholderBuilder,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 4.0,
    this.mainAxisSpacing = 4.0,
    this.childAspectRatio = 1.0,
    this.padding = const EdgeInsets.all(4.0),
    this.detailDecoration,
  });

  @override
  State<SimpleGallery<T>> createState() => _SimpleGalleryState<T>();
}

class _SimpleGalleryState<T extends Object> extends State<SimpleGallery<T>> {
  final ScrollController _controller = ScrollController();

  bool _detailShown = false;

  DetailDecoration<T> get detailDecoration =>
      widget.detailDecoration ??
      DetailDecoration(
        detailBuilder: widget.itemBuilder,
        placeholderBuilder: widget.placeholderBuilder,
      );

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _controller,
      scrollDirection: Axis.vertical,
      padding: widget.padding,
      itemCount: widget.items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: widget.childAspectRatio,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
      ),
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return SimpleItem<T>(
          item: item,
          itemSize: widget.itemSize,
          itemBuilder: widget.itemBuilder,
          placeholderBuilder: widget.placeholderBuilder,
          onTap:
              (context, item, itemSize) => _openDetail(context, item, itemSize),
        );
      },
    );
  }

  void _openDetail(BuildContext context, T item, Size itemSize) async {
    if (_detailShown) return;

    _detailShown = true;
    try {
      await showDetailPage(
        context: context,
        curItem: item,
        currItemSize: itemSize,
        itemSize: widget.itemSize,
        items: widget.items,
        onItemChanged: (value) {
          final index = widget.items.indexOf(value);
        },
        decoration: detailDecoration,
      );
    } finally {
      _detailShown = false;
    }
  }
}
