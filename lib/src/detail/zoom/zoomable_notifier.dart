import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:simple_gallery/src/detail/zoom/zoomable_notification.dart';

const kZoomAnimationDuration = Duration(milliseconds: 150);
const kFlingAnimationDuration = Duration(milliseconds: 500);
const kDragAnimationDuration = Duration(milliseconds: 250);
const kDoubleTapDistance = 50;
const kDoubleTapDurationTimeout = Duration(milliseconds: 200);
const kTapDistance = 1;
const kTapDurationTimeout = Duration(milliseconds: 100);
const kOneSecondInMs = 1000;

enum ZoomableState {
  idle,
  zooming,
  zoomed,
  moving,
  animating,
  movingPage,
  dragging,
  fling,
}

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

  final VelocityTracker _velocityTracker = VelocityTracker.withKind(
    PointerDeviceKind.touch,
  );

  final VoidCallback onTap;

  ZoomableNotifier({
    required this.context,
    required Size childSize,
    required Size viewSize,
    required this.onTap,
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
  Offset? _initialDragPosition;
  final List<PointerUpEvent> _pointerUpEvents = [];
  PointerDownEvent? _lastPointerDownEvent;

  void onPointerDown(PointerDownEvent event) {
    if (_activePointers.length == 2 ||
        value.state == ZoomableState.movingPage ||
        value.state == ZoomableState.dragging) {
      return;
    }
    _lastPointerDownEvent = event;
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
      _disposeAnimation();
      value = value.copyWith(state: ZoomableState.moving);
      _lastFocalPoint = event.position;
      _velocityTracker.addPosition(event.timeStamp, event.position);
    }
  }

  bool canMovePointer = true;
  bool canHandleTap = true;

  void onPointerMove(PointerMoveEvent event) {
    // Update the pointer position
    if ((!canMovePointer && _activePointers.length == 1) || !_activePointers.containsKey(event.pointer)) {
      return;
    }
    _activePointers[event.pointer] = event.position;

    final hasMovingPoint =
        _activePointers.length == 1 && _lastFocalPoint != null;
    if (hasMovingPoint) {
      _velocityTracker.addPosition(event.timeStamp, event.position);
    }

    // Handle the event based on the current state
    switch (value.state) {
      case ZoomableState.zooming:
        if (_activePointers.length == 2 && _initialScaleDistance != null) {
          _handleZooming();
        }
        break;

      case ZoomableState.moving:
        if (hasMovingPoint) _handleMoving(event.position);
        break;

      case ZoomableState.movingPage:
        if (hasMovingPoint) _movingPage(event.position);
        break;

      case ZoomableState.dragging:
        if (hasMovingPoint) _dragging(event.position);
        break;
      default:
        break;
    }
  }

  void onPointerUp(PointerUpEvent event) async {
    if (_activePointers.remove(event.pointer) == null) {
      return;
    }
    _pointerUpEvents.add(event);

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

      if (value.state == ZoomableState.movingPage) {
        return;
      }

      value = value.copyWith(state: ZoomableState.moving);
      _initialScaleDistance = null;
      _lastFocalPoint = _activePointers.values.first;
    }
  }

  void _onReleaseFinger() async {
    final pixelsPerSecond = _velocityTracker.getVelocity().pixelsPerSecond;

    if (_isDoubleTap()) {
      await _onDoubleTap(_pointerUpEvents.last.position);
      _pointerUpEvents.clear();
    } else if (_isTapped()) {
      await _handleTap();
    } else if (value.state == ZoomableState.dragging) {
      final fraction =
          (value.position - _initialDragPosition!).distance /
          (value.viewSize.shortestSide / 2);
      if (fraction > 0.5) {
        _sendDragEndNotification(true);
      } else {
        _sendDragEndNotification(false);
        await _dragCancel();
      }
    } else if (value.state == ZoomableState.movingPage) {
      _sendOverScrollEndNotification(pixelsPerSecond.dx);
    } else if (pixelsPerSecond != Offset.zero &&
        value.scale > value.initScale) {
      await _fling(pixelsPerSecond);
    } else {
      await _validatePositionAndScale();
    }

    value = value.copyWith(
      state:
          value.scale != value.initScale
              ? ZoomableState.zoomed
              : ZoomableState.idle,
    );
    _initialScaleDistance = null;
    _lastFocalPoint = null;
    _initialDragPosition = null;
  }

  Future<void> _onDoubleTap(Offset position) async {
    final isZoomed = value.scale != value.initScale;

    if (isZoomed) {
      await _animateToValue(
        value.initScale,
        _calcValidPosition(scale: value.initScale),
      );
    } else {
      // calc new scale value
      var newScale = 0.0;
      final scaledWidth = value.childSize.width * value.initScale;
      final scaledHeight = value.childSize.height * value.initScale;

      final viewRatio = double.parse(
        value.viewSize.aspectRatio.toStringAsFixed(3),
      );

      final childRatio = double.parse(
        value.childSize.aspectRatio.toStringAsFixed(3),
      );

      if (viewRatio > childRatio) {
        // new scale to fit width
        newScale = value.initScale * value.viewSize.width / scaledWidth;
      } else if (viewRatio < childRatio) {
        // new scale to fit height
        newScale = value.initScale * value.viewSize.height / scaledHeight;
      } else {
        newScale = value.initScale * 2;
      }

      // calc new position
      final screenCenter = Offset(
        value.viewSize.width / 2,
        value.viewSize.height / 2,
      );

      // Convert touch position to widget coordinates at initial scale
      final widgetTouchPoint = (position - value.position) / value.scale;

      // Calculate new position to center the touched point
      var newPosition = screenCenter - widgetTouchPoint * newScale;

      // // Create constrained position
      newPosition = _calcValidPosition(scale: newScale, position: newPosition);

      // Animate to new scale and position
      await _animateToValue(newScale, newPosition);
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

  Future<void> _dragCancel() async {
    final newPosition = _calcValidPosition();

    return _animateToValue(
      value.scale,
      newPosition,
      state: ZoomableState.animating,
      duration: kDragAnimationDuration,
    );
  }

  Future<dynamic> _validatePositionAndScale() async {
    final newScale = value.scale.clamp(value.initScale, value.maxScale);

    final newPosition = _calcValidPosition();

    // Update position
    return _animateToValue(newScale, newPosition);
  }

  Future<void> _fling(Offset pixelsPerSecond) async {
    final newPosition = _calcValidPosition(
      pixelsPerSecond: pixelsPerSecond / 3,
    );

    return _animateFling(newPosition);
  }

  Offset _calcValidPosition({
    Offset pixelsPerSecond = Offset.zero,
    double? scale,
    Offset? position,
  }) {
    final newScale =
        scale ?? value.scale.clamp(value.initScale, value.maxScale);

    final scaledWidth = value.childSize.width * newScale;
    final scaledHeight = value.childSize.height * newScale;

    double newX, newY;

    final newPosition = position ?? value.position;

    // Handle x-axis
    if (scaledWidth <= value.viewSize.width) {
      // Center if it fits
      newX = (value.viewSize.width - scaledWidth) / 2;
    } else {
      // Constrain if it exceeds
      var dx = newPosition.dx;
      if (pixelsPerSecond.dx.abs() > kMinFlingVelocity) {
        dx =
            dx +
            (pixelsPerSecond.dx *
                kFlingAnimationDuration.inMilliseconds /
                kOneSecondInMs);
      }

      final minX = value.viewSize.width - scaledWidth; // Negative when larger
      final maxX = 0.0;
      newX = dx.clamp(minX, maxX); // minX < maxX
    }

    // Handle y-axis
    if (scaledHeight <= value.viewSize.height) {
      // Center if it fits
      newY = (value.viewSize.height - scaledHeight) / 2;
    } else {
      // Constrain if it exceeds

      var dy = newPosition.dy;
      if (pixelsPerSecond.dy.abs() > kMinFlingVelocity) {
        dy =
            dy +
            (pixelsPerSecond.dy *
                kFlingAnimationDuration.inMilliseconds /
                kOneSecondInMs);
      }

      final minY = value.viewSize.height - scaledHeight; // Negative when larger
      final maxY = 0.0;
      newY = dy.clamp(minY, maxY); // minY < maxY
    }

    return Offset(newX, newY);
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
    final isDragging =
        newY == value.position.dy &&
        delta.dy > 0 &&
        delta.dy.abs() > delta.dx.abs();

    final isMovingPage =
        (newX == value.position.dx &&
            newY == value.position.dy &&
            delta != Offset.zero) ||
        (newX == value.position.dx && delta.dx.abs() > 8);

    if (isDragging) {
      _initialDragPosition = value.position;
      value = value.copyWith(state: ZoomableState.dragging);
    } else if (isMovingPage) {
      _sendOverScrollNotification(delta);
      value = value.copyWith(state: ZoomableState.movingPage);
    } else if (newX != value.position.dx || newY != value.position.dy) {
      value = value.copyWith(position: Offset(newX, newY));
    }
  }

  void _movingPage(Offset currentPosition) {
    if (_lastFocalPoint == null) return;

    final delta = currentPosition - _lastFocalPoint!; // Compute delta once

    _sendOverScrollNotification(delta);

    // Update last focal point
    _lastFocalPoint = currentPosition;
  }

  void _dragging(Offset currentPosition) {
    if (_lastFocalPoint == null || _initialDragPosition == null) return;

    final delta = currentPosition - _lastFocalPoint!; // Compute delta once
    final newPosition = value.position + delta;

    value = value.copyWith(position: newPosition);

    final distance = (newPosition - _initialDragPosition!).distance;
    final fraction = distance / (value.viewSize.shortestSide / 2);
    _sendDragUpdateNotification(fraction.clamp(0.0, 1.0));

    // Update last focal point
    _lastFocalPoint = currentPosition;
  }

  Future<void> _animateFling(Offset newPosition) {
    return _animateToValue(
      value.scale,
      newPosition,
      state: ZoomableState.fling,
      duration: kFlingAnimationDuration,
    );
  }

  // Animation logic for zooming
  Future<void> _animateToValue(
    double newScale,
    Offset newPosition, {
    ZoomableState state = ZoomableState.animating,
    Duration duration = kZoomAnimationDuration,
  }) async {
    _disposeAnimation();

    final controller = AnimationController(
      duration: duration,
      vsync: _ZoomableTickerProvider(),
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.decelerate,
    );

    _animationController = controller;
    value = value.copyWith(state: state);

    final valueTween = _ValueTween(
      value,
      value.copyWith(scale: newScale, position: newPosition),
    );

    controller.addListener(() {
      value = valueTween.evaluate(animation);
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

  void _sendDragUpdateNotification(double fraction) {
    DragUpdateNotification(fraction).dispatch(context);
  }

  void _sendDragEndNotification(bool popBack) {
    DragEndNotification(popBack).dispatch(context);
  }

  bool _isDoubleTap() {
    if (_pointerUpEvents.length < 2) return false;

    final lastPointerUpEvent = _pointerUpEvents.last;
    final almostLastPointerUpEvent =
        _pointerUpEvents[_pointerUpEvents.length - 2];

    final isDoubleTap =
        (lastPointerUpEvent.position - almostLastPointerUpEvent.position)
                .distance <
            kDoubleTapDistance &&
        (lastPointerUpEvent.timeStamp - almostLastPointerUpEvent.timeStamp) <
            kDoubleTapDurationTimeout;

    return isDoubleTap;
  }

  bool _isTapped() {
    final lastPointerDownEvent = _lastPointerDownEvent;
    final lastPointerUpEvent = _pointerUpEvents.lastOrNull;

    if (lastPointerDownEvent == null || lastPointerUpEvent == null) {
      return false;
    }

    if (lastPointerUpEvent.pointer != lastPointerDownEvent.pointer) {
      return false;
    }

    final isTap =
        (lastPointerDownEvent.position - lastPointerUpEvent.position).distance <
            kTapDistance &&
        (lastPointerUpEvent.timeStamp - lastPointerDownEvent.timeStamp) <
            kTapDurationTimeout;

    return isTap;
  }

  Future<void> _handleTap() async {
    if (!canHandleTap) return;
    
    await Future.delayed(kDoubleTapDurationTimeout);
    if (!_isDoubleTap()) {
      onTap();
      _pointerUpEvents.clear();
    }
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
