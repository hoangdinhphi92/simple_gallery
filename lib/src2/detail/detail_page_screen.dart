import 'package:flutter/material.dart';
import 'package:simple_gallery/src2/detail/detail_decoration.dart';
import 'package:simple_gallery/src2/detail/detail_item_preview.dart';
import 'package:simple_gallery/src2/detail/zoom/zoomable_notification.dart';
import 'package:simple_gallery/src2/gallery/simple_gallery.dart';

typedef DetailActionBuilder<T extends Object> =
    Widget Function(BuildContext context, T item);

Future<dynamic> showDetailPage<T extends Object>({
  required BuildContext context,
  T? curItem,
  Size? currItemSize,
  required List<T> items,
  required ItemSize<T> itemSize,
  required ValueChanged<T> onItemChanged,
  required DetailDecoration<T> decoration,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return DetailPageScreen<T>(
          curItem: curItem,
          currItemSize: currItemSize,
          items: items,
          itemSize: itemSize,
          onItemChanged: onItemChanged,
          itemBuilder: decoration.detailBuilder,
          placeholderBuilder: decoration.placeholderBuilder,
          headerBuilder: decoration.headerBuilder,
          footerBuilder: decoration.footerBuilder,
          pageGap: decoration.pageGap,
          backgroundWidget: decoration.backgroundWidget,
        );
      },
    ),
  );
}

class DetailPageScreen<T extends Object> extends StatefulWidget {
  final T? curItem;
  final Size? currItemSize;

  final List<T> items;
  final ItemSize<T> itemSize;

  final ValueChanged<T>? onItemChanged;
  final ItemBuilder<T> itemBuilder;
  final PlaceholderBuilder<T>? placeholderBuilder;

  /// Builder for the header widget (e.g., title, close button).
  final DetailActionBuilder<T>? headerBuilder;

  /// Builder for the footer widget (e.g., captions, controls).
  final DetailActionBuilder<T>? footerBuilder;

  /// Gap between items when swiping in the PageView.
  final double pageGap;

  /// Optional background widget for the detail screen.
  final Widget? backgroundWidget;

  const DetailPageScreen({
    super.key,
    this.curItem,
    this.currItemSize,
    required this.items,
    required this.itemSize,
    required this.itemBuilder,
    this.placeholderBuilder,
    this.onItemChanged,
    this.headerBuilder,
    this.footerBuilder,
    required this.pageGap,
    this.backgroundWidget,
  });

  @override
  State<DetailPageScreen<T>> createState() => _DetailPageScreenState<T>();
}

class _DetailPageScreenState<T extends Object>
    extends State<DetailPageScreen<T>> {
  PageController? _controller;

  PageController _getPageController(BoxConstraints constraints) {
    final initialPage =
        widget.curItem != null ? widget.items.indexOf(widget.curItem!) : 0;

    _controller ??= PageController(
      initialPage: initialPage,
      viewportFraction: 1 + (widget.pageGap / constraints.maxWidth),
    );
    return _controller!;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _buildBackground()),
        Positioned.fill(child: _buildPageView()),
        Positioned(
          left: 0,
          top: MediaQuery.viewPaddingOf(context).top,
          child: _buildBackButton(context),
        ),
      ],
    );
  }

  Widget _buildPageView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final controller = _getPageController(constraints);

        return NotificationListener<ZoomableNotification>(
          onNotification: _onNotification,
          child: PageView.builder(
            pageSnapping: false,
            physics: NeverScrollableScrollPhysics(),
            controller: controller,
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return FractionallySizedBox(
                widthFactor: 1 / controller.viewportFraction,
                child: DetailItemPreview(
                  item: item,
                  itemSize: widget.itemSize,
                  itemBuilder: widget.itemBuilder,
                  placeholderBuilder: widget.placeholderBuilder,
                  size: item == widget.curItem ? widget.currItemSize : null,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBackground() {
    return widget.backgroundWidget ?? ColoredBox(color: Colors.white);
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  bool _onNotification(ZoomableNotification notification) {
    final controller = _controller;
    if (controller == null) return false;

    switch (notification) {
      case OverscrollUpdateNotification():
        controller.jumpTo(
          controller.position.pixels - notification.scrollDelta.dx,
        );
        break;
      case OverscrollEndNotification():
        if (notification.velocity > 1000) {
          controller.previousPage(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        } else if (notification.velocity < -1000) {
          controller.nextPage(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        } else {
          controller.animateToPage(
            controller.page!.round(),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }

        break;
      default:
        break;
    }

    return true;
  }
}
