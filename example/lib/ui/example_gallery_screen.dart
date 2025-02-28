import 'package:flutter/material.dart';
import 'package:simple_gallery/simple_gallery.dart';

class ExampleGalleryScreen extends StatelessWidget {
  final int initialImageIndex;
  final double initialImageRatio;

  final List<String> imagePaths;
  final List<String> heroTags;
  const ExampleGalleryScreen({
    super.key,
    required this.imagePaths,
    required this.initialImageIndex,
    required this.initialImageRatio,
    required this.heroTags,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: SimpleGalleryScreen(
              imagePaths: imagePaths,
              initialImageIndex: initialImageIndex,
              initialImageRatio: initialImageRatio,
              heroTags: heroTags,
            ),
          ),
          Positioned(
            left: 0,
            top: MediaQuery.viewPaddingOf(context).top,
            width: 48,
            height: 48,
            child: _buildBackBtn(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBackBtn(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Center(child: Icon(Icons.arrow_back)),
      ),
    );
  }
}
