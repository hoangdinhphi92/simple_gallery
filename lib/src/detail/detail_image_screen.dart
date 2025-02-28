import 'dart:io';
import 'package:flutter/material.dart';
import 'package:simple_gallery/src/detail/data/hero_data.dart';
import 'package:simple_gallery/src/detail/notifier/detail_value_notifier.dart';

class DetailImageScreen extends StatefulWidget {
  final String imagePath;
  final HeroData heroData;

  const DetailImageScreen({
    super.key,
    required this.imagePath,
    required this.heroData,
  });

  @override
  State<DetailImageScreen> createState() => _DetailImageScreenState();
}

class _DetailImageScreenState extends State<DetailImageScreen> {
  late DetailValueNotifier _detailValueNotifier;
  late FileImage _imageProvider;

  @override
  void initState() {
    super.initState();
    _perpareData(widget.imagePath);
  }

  @override
  void didUpdateWidget(covariant DetailImageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _perpareData(widget.imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _detailValueNotifier.onViewSizeChanged(constraints.biggest);

        return Center(
          child: Hero(
            tag: widget.heroData.tag,
            flightShuttleBuilder: _buildFlightShuttle,
            child: Image(
              image: _imageProvider,
              fit: BoxFit.contain,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) {
                  return child;
                }

                final imageRatio = widget.heroData.imageRatio;

                if (imageRatio == null) return child;

                return AspectRatio(aspectRatio: imageRatio, child: child);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    if (flightDirection == HeroFlightDirection.push) {
      return fromHeroContext.widget;
    }
    return toHeroContext.widget;
  }

  void _perpareData(String imagePath) {
    _detailValueNotifier = DetailValueNotifier(imagePath);
    _imageProvider = FileImage(File(imagePath));
    _getImageSize();
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
