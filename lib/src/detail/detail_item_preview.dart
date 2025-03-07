import 'package:flutter/material.dart';
import 'package:simple_gallery/simple_gallery.dart';
import 'package:simple_gallery/src/detail/zoom/zoomable_preview.dart';

class DetailItemPreview<T extends Object> extends StatefulWidget {
  final T item;
  final Size? size;
  final ItemSize<T> itemSize;
  final ItemBuilder<T> itemBuilder;
  final PlaceholderBuilder<T>? placeholderBuilder;

  const DetailItemPreview({
    super.key,
    required this.item,
    this.size,
    required this.itemSize,
    required this.itemBuilder,
    this.placeholderBuilder,
  });

  @override
  State<DetailItemPreview<T>> createState() => _DetailItemPreviewState<T>();
}

class _DetailItemPreviewState<T extends Object>
    extends State<DetailItemPreview<T>> {
  Size? _itemSize;

  @override
  void initState() {
    _loadItemSize();
    super.initState();
  }

  void _loadItemSize() async {
    if (widget.size != null) {
      _itemSize = widget.size!;
      return;
    }

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
          (context, constraints) => ZoomablePreview(
            viewSize: constraints.biggest,
            childSize: size,
            child: Hero(
              tag: widget.item,
              flightShuttleBuilder: _buildFlightShuttle,
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

  Widget _buildFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    if (flightDirection == HeroFlightDirection.push) {
      return fromHeroContext.widget;
    }
    return toHeroContext.widget;
  }
}
