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
  final List<T> items;
  final ItemSize<T> itemSize;
  final ItemBuilder<T> itemBuilder;
  final PlaceholderBuilder<T>? placeholderBuilder;

  // Grid layout properties
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  // Padding around the grid
  final EdgeInsets padding;

  // Detail decoration properties
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
  Size _itemSize = Size.zero;

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
          itemBuilder: (context, item, itemSize, viewSize) {
            _itemSize = viewSize;
            return widget.itemBuilder(context, item, itemSize, viewSize);
          },
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
          if (index != -1) {
            final rowNumber = (index / widget.crossAxisCount).floor();

            final itemHeight = _itemSize.height;
            final spacingHeight = widget.mainAxisSpacing * rowNumber;
            final totalOffset = (itemHeight * rowNumber) + spacingHeight;

            final maxScrollExtent = _controller.position.maxScrollExtent;
            final clampedOffset = totalOffset.clamp(0.0, maxScrollExtent);

            _controller.jumpTo(clampedOffset);
          }
        },
        decoration: detailDecoration,
      );
    } finally {
      _detailShown = false;
    }
  }
}
