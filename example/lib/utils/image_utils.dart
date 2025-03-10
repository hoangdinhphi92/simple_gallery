import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:ui' as ui show ImmutableBuffer, TargetImageSize;

Future<Size> getLocalImageSize(String path) async {
  final completer = Completer<Size>();

  final file = File(path);
  final bytes = await file.readAsBytes();
  final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(
    bytes,
  );

  await PaintingBinding.instance.instantiateImageCodecWithSize(
    buffer,
    getTargetSize: (intrinsicWidth, intrinsicHeight) {
      completer.complete(
        Size(intrinsicWidth.toDouble(), intrinsicHeight.toDouble()),
      );
      return ui.TargetImageSize(width: 1, height: 1);
    },
  );
  return completer.future;
}

Future<Size> getNetworkImageSize(String url) async {
  final RegExp regex = RegExp(r'/(\d+)/(\d+)$');
  final Match? match = regex.firstMatch(url);

  if (match != null) {
    return Size(int.parse(match.group(1)!).toDouble(), int.parse(match.group(2)!).toDouble());
  }
  return Size.zero;
}
