import 'package:flutter/cupertino.dart';
import 'package:simple_gallery/src/detail/notifier/detail_value.dart';

class DetailValueNotifier extends ValueNotifier<DetailValue> {
  DetailValueNotifier(String imagePath) : super(DetailValue(imagePath));

  void onViewSizeChanged(Size viewSize) {
    if (value.widgetSize == viewSize) return;

    value = value.copyWith(widgetSize: viewSize);
  }

  void setImageSize(Size imageSize) {
    if (value.imageSize == imageSize) return;

    value = value.copyWith(imageSize: imageSize);
  }
}
