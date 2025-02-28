
import 'package:flutter/cupertino.dart';
import 'package:simple_gallery/src/detail/notifier/detail_value.dart';

class DetailValueNotifier extends ValueNotifier<DetailValue> {
  DetailValueNotifier(String imagePath) : super(DetailValue(imagePath));

  void onViewSizeChanged(Size viewSize, Size imageSize) {
    if(value.viewSize == viewSize) return;

    //value = value.copyWith(viewSize: viewSize);
    ////
  }


}