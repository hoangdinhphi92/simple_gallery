import 'dart:ui';

enum TouchState { idle, move, zoom }

enum DetailState { idle, zoomed, zooming, animating, moving }

class DetailValue {
  final String imagePath;
  final Size viewSize = Size.zero;
  final Size imageSize = Size.zero;
  final Size widgetSize = Size.zero;

  final double scale = 1.0;
  final Offset translate = Offset.zero;

  DetailValue(this.imagePath);

  DetailValue copyWith({String? imagePath, Size? imageSize}) {
    return DetailValue(
      imagePath ?? this.imagePath,
    );
  }
}
