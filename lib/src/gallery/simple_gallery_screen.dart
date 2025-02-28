import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_gallery/simple_gallery.dart';
import 'package:simple_gallery/src/utils/build_context_extension.dart';

class SimpleGalleryScreen extends StatefulWidget {
  final List<String> imagePaths;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets padding;
  final Widget? backgroundWidget;

  const SimpleGalleryScreen({
    super.key,
    required this.imagePaths,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 4.0,
    this.mainAxisSpacing = 4.0,
    this.childAspectRatio = 1.0,
    this.padding = EdgeInsets.zero,
    this.backgroundWidget,
  });

  @override
  State<SimpleGalleryScreen> createState() => _SimpleGalleryScreenState();
}

class _SimpleGalleryScreenState extends State<SimpleGalleryScreen> {
  final Map<String, double> _imageRatioMap = {};

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _buildBackground()),
        Positioned.fill(child: _buildGridListImage()),
      ],
    );
  }

  Widget _buildGridListImage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          scrollDirection: Axis.vertical,
          padding: widget.padding,
          itemCount: widget.imagePaths.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            childAspectRatio: widget.childAspectRatio,
            crossAxisSpacing: widget.crossAxisSpacing,
            mainAxisSpacing: widget.mainAxisSpacing,
          ),
          itemBuilder: (context, index) {
            final imagePath = widget.imagePaths[index];
            return _buildGridItem(
              context,
              imagePath,
              index,
              constraints.maxWidth,
            );
          },
        );
      },
    );
  }

  Widget _buildBackground() {
    return widget.backgroundWidget ?? ColoredBox(color: Colors.white);
  }

  GestureDetector _buildGridItem(
    BuildContext context,
    String imagePath,
    int index,
    double maxWidth,
  ) {
    final imageProvider = ResizeImage.resizeIfNeeded(
      ((maxWidth / widget.crossAxisCount) * context.devicePixelRatio).toInt(),
      null,
      FileImage(File(imagePath)),
    );

    _getImageSize(imageProvider, imagePath);

    return GestureDetector(
      onTap:
          () => _navigateToSimpleGallery(context, index, imagePath, maxWidth),
      child: Hero(
        tag: imagePath,
        child: Image(image: imageProvider, fit: BoxFit.cover),
      ),
    );
  }

  void _getImageSize(ImageProvider imageProvider, String imagePath) {
    if (_imageRatioMap[imagePath] != null) return;

    final imageStream = imageProvider.resolve(ImageConfiguration());

    final listener = ImageStreamListener((info, _) {
      _imageRatioMap[imagePath] =
          info.image.width.toDouble() / info.image.height;
    });

    imageStream.addListener(listener);
  }

  void _navigateToSimpleGallery(
    BuildContext context,
    int index,
    String imagePath,
    double screenWidth,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, animation, secondaryAnimation) {
          return DetailImageScreen(
            imagePaths: widget.imagePaths,
            initialImageIndex: index,
            initialImageRatio: _imageRatioMap[imagePath] ?? 1.0,
            screenWidth: screenWidth,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
