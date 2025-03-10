import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_gallery/src/detail/detail_decoration.dart';
import 'package:simple_gallery/src/detail/detail_item_preview.dart';
import 'package:simple_gallery/src/detail/ui/detail_default_footer.dart';
import 'package:simple_gallery/src/detail/ui/detail_default_header.dart';
import 'package:simple_gallery/src/detail/zoom/zoomable_notification.dart';
import 'package:simple_gallery/src/detail/zoom/zoomable_notifier.dart';
import 'package:simple_gallery/src/gallery/simple_gallery.dart';

typedef DetailActionBuilder<T extends Object> =
    Widget Function(
      BuildContext context,
      T item,
      PageController pageController,
    );

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
      opaque: false,
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

const kNextPageDuration = Duration(milliseconds: 250);
const kTriggerSwipeVelocity = 200;
const kFadeHeaderDuration = Duration(milliseconds: 250);

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
  double _backgroundOpacity = 1;

  double get backgroundOpacity => _backgroundOpacity;

  set backgroundOpacity(double value) {
    if (value != _backgroundOpacity && mounted) {
      _backgroundOpacity = value;
      setState(() {});
    }
  }

  PageController? _controller;

  bool _userConfirmVisible = true;
  bool get userConfirmVisible => _userConfirmVisible;
  set userConfirmVisible(bool value) {
    if (_userConfirmVisible != value) {
      _userConfirmVisible = value;
      _visibleHeader = value;
      setState(() {});
    }
  }

  bool _visibleHeader = true;
  bool get visibleHeader => _visibleHeader;
  set visibleHeader(bool value) {
    if (_visibleHeader != value) {
      _visibleHeader = value;
      setState(() {});
    }
  }

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final controller = _getPageController(constraints);
        return Stack(
          children: [
            Positioned.fill(child: _buildBackground()),
            Positioned.fill(child: _buildPageView(controller)),
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: visibleHeader ? 1.0 : 0.0,
                duration: kFadeHeaderDuration,
                child: _buildHeader(context),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedOpacity(
                opacity: visibleHeader ? 1.0 : 0.0,
                duration: kFadeHeaderDuration,
                child: _buildFooter(context),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  log("onTap");
                  userConfirmVisible = !visibleHeader;
                },
                onDoubleTap: () {
                  log("onDoubleTap");
                },
                onLongPress: () {},
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageView(PageController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
    return AnimatedOpacity(
      duration: kDragAnimationDuration,
      opacity: _backgroundOpacity,
      child: widget.backgroundWidget ?? ColoredBox(color: Colors.white),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (widget.headerBuilder != null && _controller != null) {
      return widget.headerBuilder!.call(context, widget.curItem!, _controller!);
    }

    return DetailDefaultHeader();
  }

  Widget _buildFooter(BuildContext context) {
    if (widget.footerBuilder != null && _controller != null) {
      return widget.footerBuilder!.call(context, widget.curItem!, _controller!);
    }

    return DetailDefaultFooter(
      totalPage: widget.items.length,
      pageController: _controller!,
    );
  }

  bool _onNotification(ZoomableNotification notification) {
    final controller = _controller;
    if (controller == null) return false;

    switch (notification) {
      case OverscrollUpdateNotification():
        _onOverScrollUpdate(notification, controller);
        break;
      case OverscrollEndNotification():
        return _onOverScrollEnd(notification, controller);
      case DragUpdateNotification():
        _onDragUpdate(notification);
        break;
      case DragEndNotification():
        _onDragEnd(notification);
        break;
      case ZoomStateUpdateNotification():
        _onZoomStateUpdate(notification);
        break;
    }

    return true;
  }

  void _onZoomStateUpdate(ZoomStateUpdateNotification notification) {
    if (!userConfirmVisible) return;

    switch (notification.state) {
      case ZoomableState.idle:
        visibleHeader = true;
      case ZoomableState.zooming:
      case ZoomableState.zoomed:
      case ZoomableState.dragging:
        visibleHeader = false;
      default:
        break;
    }
  }

  void _onOverScrollUpdate(
    OverscrollUpdateNotification notification,
    PageController controller,
  ) {
    controller.jumpTo(controller.position.pixels - notification.scrollDelta.dx);
  }

  bool _onOverScrollEnd(
    OverscrollEndNotification notification,
    PageController controller,
  ) {
    final page = controller.page;

    if (page == null || page == widget.items.length - 1 || page == 0) {
      return false;
    }

    final isSwipe = notification.velocity.abs() > kTriggerSwipeVelocity;
    final isSwipeNext = notification.velocity < 0;

    if (isSwipe) {
      final nextPage = page.toInt() + (isSwipeNext ? 1 : 0);
      controller.animateToPage(
        nextPage,
        duration: kNextPageDuration,
        curve: Curves.decelerate,
      );
    } else {
      final nextPage = page.round();
      controller.animateToPage(
        nextPage,
        duration: kNextPageDuration,
        curve: Curves.decelerate,
      );
    }
    return true;
  }

  void _onDragUpdate(DragUpdateNotification notification) {
    backgroundOpacity = 1 - notification.fraction;
  }

  void _onDragEnd(DragEndNotification notification) {
    if (notification.popBack) {
      backgroundOpacity = 0;
      Navigator.of(context).pop();
    } else {
      backgroundOpacity = 1;
    }
  }
}
