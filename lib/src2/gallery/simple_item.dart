
import 'package:flutter/material.dart';
import 'package:simple_gallery/src2/gallery/simple_gallery.dart';

typedef ItemTap<T extends Object> = void Function(BuildContext context, T item, Size itemSize);

class SimpleItem<T extends Object> extends StatefulWidget {
  final T item;
  final ItemSize<T> itemSize;
  final ItemBuilder<T> itemBuilder;
  final PlaceholderBuilder<T>? placeholderBuilder;

  final ItemTap<T>? onTap;

  const SimpleItem({
    super.key,
    required this.item,
    required this.itemSize,
    required this.itemBuilder,
    this.placeholderBuilder,
    this.onTap,
  });

  @override
  State<SimpleItem<T>> createState() => _SimpleItemState<T>();
}

class _SimpleItemState<T extends Object> extends State<SimpleItem<T>> {
  Size? _itemSize;

  @override
  void initState() {
    _loadItemSize();
    super.initState();
  }

  void _loadItemSize() async {
    _itemSize = await widget.itemSize(widget.item);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = _itemSize;

    if (size == null) {
      return widget.placeholderBuilder?.call(context, widget.item) ??
          SizedBox.expand();
    }

    return LayoutBuilder(
      builder:
          (context, constraints) => GestureDetector(
            onTap: () => widget.onTap?.call(context, widget.item, size),
            child: Hero(
              tag: widget.item,
              child: widget.itemBuilder(
                context,
                widget.item,
                size,
                constraints.biggest,
              ),
            ),
          ),
    );
  }
}
