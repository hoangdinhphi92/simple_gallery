import 'package:flutter/material.dart';

extension MediaQueryContext on BuildContext {
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  Size get viewSize => MediaQuery.sizeOf(this);

  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(this);
}
