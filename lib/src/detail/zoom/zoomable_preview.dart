import 'package:flutter/material.dart';
import 'package:simple_gallery/src/detail/zoom/zoomable_notifier.dart';

class ZoomablePreview extends StatefulWidget {
  final Size viewSize;
  final Size childSize;

  final Widget child;

  final VoidCallback onTap;

  const ZoomablePreview({
    super.key,
    required this.viewSize,
    required this.childSize,
    required this.child,
    required this.onTap,
  });

  @override
  State<ZoomablePreview> createState() => ZoomablePreviewState();
}

class ZoomablePreviewState extends State<ZoomablePreview> {
  late final ZoomableNotifier zoomableNotifier = ZoomableNotifier(
    context: context,
    viewSize: widget.viewSize,
    childSize: widget.childSize,
    onTap: widget.onTap,
  );

  @override
  void dispose() {
    zoomableNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: zoomableNotifier,
      builder:
          (context, value, child) => Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: zoomableNotifier.onPointerDown,
            onPointerMove: zoomableNotifier.onPointerMove,
            onPointerUp: zoomableNotifier.onPointerUp,
            onPointerCancel: zoomableNotifier.onPointerCancel,
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
