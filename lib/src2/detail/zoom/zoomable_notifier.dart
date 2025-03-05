import 'dart:developer';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:simple_gallery/src2/detail/zoom/zoomable_notification.dart';

const kAnimationDuration = Duration(milliseconds: 150);

enum ZoomableState { idle, zooming, moving, animating }

class ZoomableValue {
  final Size viewSize;
  final Size childSize;
  final ZoomableState state;

  final double scale;
  final Offset position;

  final double minScale;
  final double maxScale;
  final double initScale;

  const ZoomableValue({
    required this.viewSize,
    required this.childSize,
    this.state = ZoomableState.idle,
    this.scale = 1.0,
    this.minScale = 1.0,
    this.maxScale = 5.0,
    this.initScale = 1.0,
    this.position = Offset.zero,
  });

  factory ZoomableValue.from(Size viewSize, Size childSize) {
    // Calculate the aspect ratio of the child
    double aspectRatio = childSize.width / childSize.height;

    // Calculate the new scale to maintain the aspect ratio
    double newScale;
    if (viewSize.aspectRatio > aspectRatio) {
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
      initScale: newScale,
      minScale: newScale * 0.5,
      maxScale: newScale * 5,
    );
  }

  ZoomableValue copyWith({
    Size? viewSize,
    Size? childSize,
    ZoomableState? state,
    double? scale,
    Offset? position,
    double? minScale,
    double? maxScale,
    double? initScale,
  }) {
    return ZoomableValue(
      viewSize: viewSize ?? this.viewSize,
      childSize: childSize ?? this.childSize,
      state: state ?? this.state,
      scale: scale ?? this.scale,
      position: position ?? this.position,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      initScale: initScale ?? this.initScale,
    );
  }

  @override
  String toString() {
    return 'ZoomableValue{viewSize: $viewSize, childSize: $childSize, state: $state, scale: $scale, position: $position, minScale: $minScale, maxScale: $maxScale, initScale: $initScale}';
  }
}

class ZoomableNotifier extends ValueNotifier<ZoomableValue> {
  final BuildContext context;
  AnimationController? _animationController;

  ZoomableNotifier({
    required this.context,
    required Size childSize,
    required Size viewSize,
  }) : super(ZoomableValue.from(viewSize, childSize));

  @override
  set value(ZoomableValue newValue) {
    if (super.value.state != newValue.state) {
      _sendStateUpdateNotification(newValue.state);
    }
    super.value = newValue;
  }

  // Track active pointers for gesture detection
  final Map<int, Offset> _activePointers = {};
  double? _initialScaleDistance;
  Offset? _lastFocalPoint;

  void onPointerDown(PointerDownEvent event) {
    if (_activePointers.length == 2) return;
    _activePointers[event.pointer] = event.position;

    // If we have exactly 2 pointers, we'll start zooming
    if (_activePointers.length == 2) {
      _disposeAnimation();

      value = value.copyWith(state: ZoomableState.zooming);
      _initialScaleDistance = _getPointersDistance();
      _lastFocalPoint = _calculateFocalPoint();
    }
    // If we have exactly 1 pointer, we'll start moving
    else if (_activePointers.length == 1 &&
        value.state != ZoomableState.animating) {
      value = value.copyWith(state: ZoomableState.moving);
      _lastFocalPoint = event.position;
      _velocityTracker.addPosition(event.timeStamp, event.position);
    }
  }

  final VelocityTracker _velocityTracker = VelocityTracker.withKind(
    PointerDeviceKind.touch,
  );

  void onPointerMove(PointerMoveEvent event) {
    // Update the pointer position
    if (!_activePointers.containsKey(event.pointer)) {
      return;
    }
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
          _velocityTracker.addPosition(event.timeStamp, event.position);
          log(
            "event.position: ${event.position} | timeStamp: ${event.timeStamp}",
          );
        }
        break;

      default:
        break;
    }
  }

  void onPointerUp(PointerUpEvent event) async {
    _activePointers.remove(event.pointer);
    _onPointerUp();
  }

  void onPointerCancel(PointerCancelEvent event) {
    _activePointers.remove(event.pointer);
    _onPointerUp();
  }

  void _onPointerUp() async {
    // Reset to idle state if no pointers are active
    if (_activePointers.isEmpty) {
      _onReleaseFinger();
    }
    // If we still have pointers, adjust the state accordingly
    else if (_activePointers.length == 1) {
      if (value.state == ZoomableState.zooming) {
        await _validatePositionAndScale();
      }
      value = value.copyWith(state: ZoomableState.moving);
      _initialScaleDistance = null;
      _lastFocalPoint = _activePointers.values.first;
    }
  }

  void _onReleaseFinger() async {
    await _validatePositionAndScale();

    value = value.copyWith(state: ZoomableState.idle);
    _initialScaleDistance = null;
    _lastFocalPoint = null;

    _sendOverScrollEndNotification(
      _velocityTracker.getVelocity().pixelsPerSecond.dx,
    );
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

    final pointers = _activePointers.values;
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
      // Calculate new scale based on pointer distance change
      final scaleFactor = currentDistance / _initialScaleDistance!;
      final newScale = (value.scale * scaleFactor).clamp(
        value.minScale,
        value.maxScale,
      );

      // Convert focal point to widget coordinates before scaling
      final widgetFocalPoint = (focalPoint - value.position) / value.scale;

      // Calculate new position to maintain focal point screen position
      final newPosition = focalPoint - widgetFocalPoint * newScale;

      // Update value with new scale and position
      value = value.copyWith(scale: newScale, position: newPosition);
      _handleMoving(focalPoint, zooming: true);

      // Update tracking variables for next iteration
      _initialScaleDistance = currentDistance;
      _lastFocalPoint = focalPoint;
    }
  }

  // Handle moving/panning logic
  void _handleMoving(Offset currentPosition, {bool zooming = false}) {
    if (_lastFocalPoint == null) return;

    final delta = currentPosition - _lastFocalPoint!; // Compute delta once

    // Update the position
    if (!zooming) {
      _constrainMoving(delta: delta);
    } else {
      final newPosition = value.position.translate(delta.dx, delta.dy);
      value = value.copyWith(position: newPosition);
    }

    // Update last focal point
    _lastFocalPoint = currentPosition;
  }

  Future<dynamic> _validatePositionAndScale() async {
    final newScale = value.scale.clamp(value.initScale, value.maxScale);

    final scaledWidth = value.childSize.width * newScale;
    final scaledHeight = value.childSize.height * newScale;

    double newX, newY;

    // Handle x-axis
    if (scaledWidth <= value.viewSize.width) {
      // Center if it fits
      newX = (value.viewSize.width - scaledWidth) / 2;
    } else {
      // Constrain if it exceeds
      final minX = value.viewSize.width - scaledWidth; // Negative when larger
      final maxX = 0.0;
      newX = value.position.dx.clamp(minX, maxX); // minX < maxX
    }

    // Handle y-axis
    if (scaledHeight <= value.viewSize.height) {
      // Center if it fits
      newY = (value.viewSize.height - scaledHeight) / 2;
    } else {
      // Constrain if it exceeds
      final minY = value.viewSize.height - scaledHeight; // Negative when larger
      final maxY = 0.0;
      newY = value.position.dy.clamp(minY, maxY); // minY < maxY
    }

    // Update position
    // value = value.copyWith(scale: newScale, position: Offset(newX, newY));
    return _animateToValue(newScale, Offset(newX, newY));
  }

  void _constrainMoving({Offset delta = Offset.zero}) {
    // Calculate scaled dimensions once
    final scaledWidth = value.childSize.width * value.scale;
    final scaledHeight = value.childSize.height * value.scale;
    // Handle x-axis movement if widget width exceeds view width
    double newX = value.position.dx;
    if (scaledWidth > value.viewSize.width) {
      newX = (value.position.dx + delta.dx).clamp(
        -(scaledWidth -
            value.viewSize.width), // Minimum x (left edge constraint)
        0.0, // Maximum x (right edge constraint)
      );
    }

    // Handle y-axis movement if widget height exceeds view height
    double newY = value.position.dy;
    if (scaledHeight > value.viewSize.height) {
      newY = value.position.dy + delta.dy;
      newY = newY.clamp(-(scaledHeight - value.viewSize.height), 0.0);
    }

    // Update position if there's a change
    if (newX != value.position.dx || newY != value.position.dy) {
      value = value.copyWith(position: Offset(newX, newY));
    } else {
      _sendOverScrollNotification(delta);
    }
  }

  // Animation logic for zooming
  Future<void> _animateToValue(double newScale, Offset newPosition) async {
    _disposeAnimation();

    final controller = AnimationController(
      duration: kAnimationDuration,
      vsync: _ZoomableTickerProvider(),
    );

    _animationController = controller;
    value = value.copyWith(state: ZoomableState.animating);

    final valueTween = _ValueTween(
      value,
      value.copyWith(scale: newScale, position: newPosition),
    );

    _animationController?.addListener(() {
      value = valueTween.evaluate(controller);
    });

    await controller.forward();
    _disposeAnimation();
  }

  void _disposeAnimation() {
    _animationController?.dispose();
    _animationController = null;
  }

  // Send a notification to the parent widget
  void _sendOverScrollNotification(Offset scrollDelta) {
    OverscrollUpdateNotification(scrollDelta).dispatch(context);
  }

  void _sendOverScrollEndNotification(double velocity) {
    OverscrollEndNotification(velocity).dispatch(context);
  }

  void _sendStateUpdateNotification(ZoomableState state) {
    ZoomStateUpdateNotification(state).dispatch(context);
  }

  @override
  void dispose() {
    _disposeAnimation();
    super.dispose();
  }
}

class _ZoomableTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

class _ValueTween extends Animatable<ZoomableValue> {
  _ValueTween(this.begin, this.end);

  final ZoomableValue begin;
  final ZoomableValue end;

  @override
  ZoomableValue transform(double t) {
    return begin.copyWith(
      scale: begin.scale + (end.scale - begin.scale) * t,
      position: begin.position + (end.position - begin.position) * t,
    );
  }
}
