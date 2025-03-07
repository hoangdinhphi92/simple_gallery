import 'package:flutter/material.dart';
import 'package:simple_gallery/src/detail/zoom/zoomable_notifier.dart';

class ZoomablePreview extends StatefulWidget {
  final Size viewSize;
  final Size childSize;

  final Widget child;

  const ZoomablePreview({
    super.key,
    required this.viewSize,
    required this.childSize,
    required this.child,
  });

  @override
  State<ZoomablePreview> createState() => _ZoomablePreviewState();
}

class _ZoomablePreviewState extends State<ZoomablePreview> {
  late final ZoomableNotifier _zoomableNotifier = ZoomableNotifier(
    context: context,
    viewSize: widget.viewSize,
    childSize: widget.childSize,
  );

  @override
  void dispose() {
    _zoomableNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _zoomableNotifier,
      builder:
          (context, value, child) => Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _zoomableNotifier.onPointerDown,
            onPointerMove: _zoomableNotifier.onPointerMove,
            onPointerUp: _zoomableNotifier.onPointerUp,
            onPointerCancel: _zoomableNotifier.onPointerCancel,
            child: _buildChild(context, value),
          ),
    );
  }

  Widget _buildChild(BuildContext context, ZoomableValue value) {
    return Stack(
      children: [
        Positioned.fromRect(
          rect: Rect.fromLTWH(
            value.position.dx,
            value.position.dy,
            widget.childSize.width * value.scale,
            widget.childSize.height * value.scale,
          ),
          child: widget.child,
        ),
      ],
    );
  }
}
