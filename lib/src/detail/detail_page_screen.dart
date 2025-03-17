import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      List<T> items,
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
          backgroundBuilder: decoration.backgroundBuilder,
          systemUiOverlayStyle: decoration.systemUiOverlayStyle,
          tapToHide: decoration.tapToHide,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

const kNextPageDuration = Duration(milliseconds: 250);
const kTriggerSwipeVelocity = 200;
const kFadeHeaderDuration = Duration(milliseconds: 200);

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
  final BackgroundBuilder? backgroundBuilder;

  /// System UI overlay style for the detail screen.
  final SystemUiOverlayStyle? systemUiOverlayStyle;

  /// Hide action buttons when tapping on the screen.
  final bool tapToHide;

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
    this.backgroundBuilder,
    this.systemUiOverlayStyle,
    this.tapToHide = true,
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

  T? _currentItem;

  T? get currentItem => _currentItem ?? widget.curItem;

  set currentItem(T? value) {
    if (_currentItem != value && mounted) {
      _currentItem = value;
      if (_currentItem != null) {
        widget.onItemChanged?.call(currentItem!);
      }
      setState(() {});
    }
  }

  PageController? _controller;

  bool _overlayVisible = false;

  bool get overlayVisible => _overlayVisible;

  set overlayVisible(bool value) {
    if (_overlayVisible != value && mounted) {
      _overlayVisible = value;
      setState(() {});
    }
  }

  SystemUiOverlayStyle? _lastSystemUiOverlayStyle;

  @override
  void initState() {
    super.initState();
    _updateSystemUiOverlayStyle();
    _showHeaderAndFooterAfterPageTransition();
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
              child: _buildAnimatedOpacityWrapper(
                overlayVisible,
                child: _buildHeader(context, controller),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildAnimatedOpacityWrapper(
                overlayVisible,
                child: _buildFooter(context, controller),
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
                  onTap: () {
                    if (widget.tapToHide) {
                      overlayVisible = !overlayVisible;
                    }
                  },
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
      child:
          widget.backgroundBuilder?.call(context) ??
          ColoredBox(color: Colors.white),
    );
  }

  Widget _buildHeader(BuildContext context, PageController controller) {
    if (widget.headerBuilder != null && currentItem != null) {
      return widget.headerBuilder!.call(
        context,
        widget.items,
        currentItem!,
        controller,
      );
    }

    return DetailDefaultHeader();
  }

  Widget _buildFooter(BuildContext context, PageController controller) {
    if (currentItem == null) {
      return const SizedBox.shrink();
    }

    if (widget.footerBuilder != null) {
      return widget.footerBuilder!.call(
        context,
        widget.items,
        currentItem!,
        controller,
      );
    }

    return DetailDefaultFooter(
      items: widget.items,
      currentItem: currentItem,
      pageController: controller,
    );
  }

  Widget _buildAnimatedOpacityWrapper(bool visible, {required Widget child}) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: kFadeHeaderDuration,
        child: child,
      ),
    );
  }

  PageController _getPageController(BoxConstraints constraints) {
    if (_controller != null) return _controller!;

    final initialPage =
        widget.curItem != null ? widget.items.indexOf(widget.curItem!) : 0;

    _controller = PageController(
      initialPage: initialPage,
      viewportFraction: 1 + (widget.pageGap / constraints.maxWidth),
    );

    _controller!.addListener(_onPageChanged);

    return _controller!;
  }

  void _onPageChanged() {
    final pageIndex = _controller?.page?.round();
    if (pageIndex == null) return;

    currentItem = widget.items[pageIndex];
  }

  void _showHeaderAndFooterAfterPageTransition() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var route = ModalRoute.of(context);

      void handler(status) {
        if (status == AnimationStatus.completed) {
          overlayVisible = true;
          route?.animation?.removeStatusListener(handler);
        }
      }

      route?.animation?.addStatusListener(handler);
    });
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
    switch (notification.state) {
      case ZoomableState.animating:
      case ZoomableState.zooming:
      case ZoomableState.dragging:
        if (widget.tapToHide) overlayVisible = false;
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

  @override
  void dispose() {
    _restoreSystemUiOverlayStyle();
    _controller?.removeListener(_onPageChanged);
    super.dispose();
  }

  void _updateSystemUiOverlayStyle() {
    final style = widget.systemUiOverlayStyle;
    if (style != null) {
      _lastSystemUiOverlayStyle = SystemChrome.latestStyle;
      SystemChrome.setSystemUIOverlayStyle(style);
    }
  }

  void _restoreSystemUiOverlayStyle() {
    if (_lastSystemUiOverlayStyle != null) {
      SystemChrome.setSystemUIOverlayStyle(_lastSystemUiOverlayStyle!);
    }
  }
}
