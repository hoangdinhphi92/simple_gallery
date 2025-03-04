import 'dart:ui';

import 'package:flutter/cupertino.dart';

enum ZoomableState { idle, zooming, moving }

class ZoomableValue {
  final Size viewSize;
  final Size childSize;
  final ZoomableState state;

  final double scale;
  final Offset position;

  const ZoomableValue({
    required this.viewSize,
    required this.childSize,
    this.state = ZoomableState.idle,
    this.scale = 1.0,
    this.position = Offset.zero,
  });

  factory ZoomableValue.from(Size viewSize, Size childSize) {
    // Calculate the aspect ratio of the child
    double aspectRatio = childSize.width / childSize.height;

    // Calculate the new scale to maintain the aspect ratio
    double newScale;
    if (viewSize.width / viewSize.height > aspectRatio) {
      newScale = viewSize.height / childSize.height;
    } else {
      newScale = viewSize.width / childSize.width;
    }

    // Adjust the position to keep the child centered
    Offset newPosition = Offset(
      (viewSize.width - childSize.width * newScale) / 2,
      (viewSize.height - childSize.height * newScale) / 2,
    );

    // Update the value with the new scale and position
    return ZoomableValue(
      viewSize: viewSize,
      childSize: childSize,
      position: newPosition,
      scale: newScale,
    );
  }

  ZoomableValue copyWith({
    Size? viewSize,
    Size? childSize,
    ZoomableState? state,
    double? scale,
    Offset? position,
  }) {
    return ZoomableValue(
      viewSize: viewSize ?? this.viewSize,
      childSize: childSize ?? this.childSize,
      state: state ?? this.state,
      scale: scale ?? this.scale,
      position: position ?? this.position,
    );
  }

  @override
  String toString() {
    return 'ZoomableValue{viewSize: $viewSize, childSize: $childSize, state: $state, scale: $scale, position: $position}';
  }
}

class ZoomableNotifier extends ValueNotifier<ZoomableValue> {
  ZoomableNotifier({required Size childSize, required Size viewSize})
    : super(ZoomableValue.from(viewSize, childSize));

  // Constants for zooming and panning
  static const double minScale = 0.8;
  static const double maxScale = 5.0;

  // Track active pointers for gesture detection
  final Map<int, Offset> _activePointers = {};
  double? _initialScaleDistance;
  Offset? _lastFocalPoint;

  void onPointerDown(PointerDownEvent event) {
    _activePointers[event.pointer] = event.position;

    // If we have exactly 2 pointers, we'll start zooming
    if (_activePointers.length == 2) {
      value = value.copyWith(state: ZoomableState.zooming);
      _initialScaleDistance = _getPointersDistance();
      _lastFocalPoint = _calculateFocalPoint();
    }
    // If we have exactly 1 pointer, we'll start moving
    else if (_activePointers.length == 1) {
      value = value.copyWith(state: ZoomableState.moving);
      _lastFocalPoint = event.position;
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    // Update the pointer position
    _activePointers[event.pointer] = event.position;

    switch (value.state) {
      case ZoomableState.zooming:
        if (_activePointers.length == 2 && _initialScaleDistance != null) {
          _handleZooming();
        }
        break;

      case ZoomableState.moving:
        if (_activePointers.length == 1 && _lastFocalPoint != null) {
          _handleMoving(event.position);
        }
        break;

      case ZoomableState.idle:
        // Do nothing if we're idle
        break;
    }
  }

  void onPointerUp(PointerUpEvent event) {
    _activePointers.remove(event.pointer);

    // Reset to idle state if no pointers are active
    if (_activePointers.isEmpty) {
      value = value.copyWith(state: ZoomableState.idle);
      _initialScaleDistance = null;
      _lastFocalPoint = null;
    }
    // If we still have pointers, adjust the state accordingly
    else if (_activePointers.length == 1) {
      value = value.copyWith(state: ZoomableState.moving);
      _initialScaleDistance = null;
      _lastFocalPoint = _activePointers.values.first;
    }
  }

  void onPointerCancel(PointerCancelEvent event) {
    _activePointers.remove(event.pointer);

    // Reset to idle state if no pointers are active
    if (_activePointers.isEmpty) {
      value = value.copyWith(state: ZoomableState.idle);
      _initialScaleDistance = null;
      _lastFocalPoint = null;
    }
  }

  // Helper method to calculate distance between pointers
  double _getPointersDistance() {
    if (_activePointers.length < 2) return 0.0;

    final pointers = _activePointers.values.toList();
    return (pointers[0] - pointers[1]).distance;
  }

  // Helper method to calculate focal point between pointers
  Offset _calculateFocalPoint() {
    if (_activePointers.isEmpty) return Offset.zero;

    final pointers = _activePointers.values.toList();
    double x = 0.0, y = 0.0;

    for (var pointer in pointers) {
      x += pointer.dx;
      y += pointer.dy;
    }

    return Offset(x / pointers.length, y / pointers.length);
  }

  // Handle zooming logic
  void _handleZooming() {
    final currentDistance = _getPointersDistance();
    final focalPoint = _calculateFocalPoint();

    if (_initialScaleDistance != null && _initialScaleDistance! > 0) {
      // Calculate new scale based on the change in distance
      final scaleFactor = currentDistance / _initialScaleDistance!;
      final newScale = value.scale * scaleFactor;

      // Constrain scale within bounds
      final constrainedScale = newScale.clamp(minScale, maxScale);

      // Calculate the position adjustment to zoom toward the focal point
      final viewCenter = Offset(
        value.viewSize.width / 2,
        value.viewSize.height / 2,
      );
      final focalPointOffset = focalPoint - viewCenter;
      final scaleDiff = constrainedScale / value.scale;

      final newPosition = Offset(
        value.position.dx - focalPointOffset.dx * (scaleDiff - 1),
        value.position.dy - focalPointOffset.dy * (scaleDiff - 1),
      );

      // Update the value
      value = value.copyWith(scale: constrainedScale, position: newPosition);

      // Reset the initial distance for the next move
      _initialScaleDistance = currentDistance;
      _lastFocalPoint = focalPoint;
    }
  }

  // Handle moving/panning logic
  void _handleMoving(Offset currentPosition) {
    if (_lastFocalPoint != null) {
      // Calculate the movement delta
      final delta = currentPosition - _lastFocalPoint!;
      final newPosition = value.position.translate(delta.dx, delta.dy);

      // Update the position
      value = value.copyWith(position: newPosition);
      _lastFocalPoint = currentPosition;
    }
  }

  // Utility method to reset the view to fit the content
  void resetView() {
    value = ZoomableValue.from(value.viewSize, value.childSize);
  }
}
