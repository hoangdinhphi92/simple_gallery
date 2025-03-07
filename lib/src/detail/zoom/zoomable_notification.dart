import 'package:flutter/material.dart';
import 'package:simple_gallery/src/detail/zoom/zoomable_notifier.dart';

sealed class ZoomableNotification extends Notification {}

class ZoomStateUpdateNotification extends ZoomableNotification {
  final ZoomableState state;

  ZoomStateUpdateNotification(this.state);
}

class OverscrollUpdateNotification extends ZoomableNotification {
  final Offset scrollDelta;

  OverscrollUpdateNotification(this.scrollDelta);
}

class OverscrollEndNotification extends ZoomableNotification {
  final double velocity;

  OverscrollEndNotification(this.velocity);
}

class DragUpdateNotification extends ZoomableNotification {
  final double fraction;

  DragUpdateNotification(this.fraction);
}

class DragEndNotification extends ZoomableNotification {
  final bool popBack;

  DragEndNotification(this.popBack);
}
