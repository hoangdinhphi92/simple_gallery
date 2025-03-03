import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_gallery/simple_gallery.dart';
import 'package:simple_gallery/src/utils/build_context_extension.dart';

typedef DetailImageScreenBuilder =
    DetailImageScreen Function(BuildContext context);

class SimpleGalleryScreen extends StatefulWidget {
  /// List of image file paths to be displayed in the gallery.
  final List<String> imagePaths;

  /// Number of columns in the grid layout.
  final int crossAxisCount;

  /// Spacing between columns in the grid.
  final double crossAxisSpacing;

  /// Spacing between rows in the grid.
  final double mainAxisSpacing;

  /// Aspect ratio of each grid item (width / height).
  final double childAspectRatio;

  /// Padding around the grid.
  final EdgeInsets padding;

  /// Optional background widget for the gallery screen.
  final Widget? backgroundWidget;

  /// Optional background widget for the detail image screen.
  final Widget? detailImageBackgroundWidget;

  /// Builder for the header widget in the detail image screen.
  final DetailImageHeaderBuidler? detailImageHeaderBuilder;

  /// Builder for the footer widget in the detail image screen.
  final DetailImageFooterBuidler? detailImageFooterBuilder;

  /// Gap between images when swiping in the detail image screen.
  final double detailImagePageGap;

  const SimpleGalleryScreen({
    super.key,
    required this.imagePaths,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 4.0,
    this.mainAxisSpacing = 4.0,
    this.childAspectRatio = 1.0,
    this.padding = EdgeInsets.zero,
    this.backgroundWidget,
    this.detailImageBackgroundWidget,
    this.detailImageHeaderBuilder,
    this.detailImageFooterBuilder,
    this.detailImagePageGap = 16,
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

  Widget _buildGridItem(
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
          () => _navigateToDetailImageScreen(context, index, imagePath, maxWidth),
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

  void _navigateToDetailImageScreen(
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
            backgroundWidget: widget.detailImageBackgroundWidget,
            headerBuilder: widget.detailImageHeaderBuilder,
            footerBuilder: widget.detailImageFooterBuilder,
            pageGap: widget.detailImagePageGap,
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
