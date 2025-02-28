import 'dart:io';
import 'package:flutter/material.dart';
import 'package:simple_gallery/src/detail/notifier/detail_value_notifier.dart';

class DetailImageScreen extends StatefulWidget {
  final String imagePath;

  const DetailImageScreen({super.key, required this.imagePath});

  @override
  State<DetailImageScreen> createState() => _DetailImageScreenState();
}

class _DetailImageScreenState extends State<DetailImageScreen> {
  late final DetailValueNotifier _detailValueNotifier;
  late final FileImage _imageProvider = FileImage(File(widget.imagePath));

  @override
  void initState() {
    super.initState();
    _detailValueNotifier = DetailValueNotifier(widget.imagePath);
    _getImageSize();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _detailValueNotifier.onViewSizeChanged(constraints.biggest);

        return Image(image: _imageProvider, fit: BoxFit.contain);
      },
    );
  }

  void _getImageSize() {
    final imageStream = _imageProvider.resolve(ImageConfiguration());

    final listener = ImageStreamListener((info, _) {
      _detailValueNotifier.setImageSize(
        Size(info.image.width.toDouble(), info.image.height.toDouble()),
      );
    });

    imageStream.addListener(listener);
  }
}
