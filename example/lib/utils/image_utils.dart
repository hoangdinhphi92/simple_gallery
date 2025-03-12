import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui show ImmutableBuffer, TargetImageSize;
import 'package:http/http.dart' as http;

Future<Size> getLocalImageSize(String path) async {
  final file = File(path);
  final bytes = await file.readAsBytes();
  return getImageSizeFromBytes(bytes);
}

Future<Size> getNetworkImageSize(String url) async {
  final bytes = await _getResponseImageUrl(url);
  if (bytes != null) {
    return getImageSizeFromBytes(bytes);
  }
  return Size.zero;
}

Future<Size> getImageSizeFromBytes(Uint8List bytes) async {
  final completer = Completer<Size>();

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

Future<Uint8List?> _getResponseImageUrl(String url) async {
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      print('Failed to load image. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error loading image: $e');
    return null;
  }
}
