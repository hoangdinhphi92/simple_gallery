import 'dart:ui';

enum TouchState { idle, move, zoom }

enum DetailState { idle, zoomed, zooming, animating, moving }

class DetailValue {
  final String imagePath;
  final Size imageSize;
  final Size widgetSize;

  final double scale = 1.0;
  final Offset translate = Offset.zero;

  DetailValue(
    this.imagePath, {
    this.imageSize = Size.zero,
    this.widgetSize = Size.zero,
  });

  DetailValue copyWith({String? imagePath, Size? imageSize, Size? widgetSize}) {
    return DetailValue(
      imagePath ?? this.imagePath,
      imageSize: imageSize ?? this.imageSize,
      widgetSize: widgetSize ?? this.widgetSize,
    );
  }
}
