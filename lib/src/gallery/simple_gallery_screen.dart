import 'package:flutter/material.dart';
import 'package:simple_gallery/simple_gallery.dart';
import 'package:simple_gallery/src/detail/data/hero_data.dart';

class SimpleGalleryScreen extends StatefulWidget {
  final int initialImageIndex;
  final double initialImageRatio;

  final List<String> imagePaths;
  final List<String> heroTags;

  SimpleGalleryScreen({
    super.key,
    required this.imagePaths,
    required this.initialImageIndex,
    required this.initialImageRatio,
    required this.heroTags,
  }) {
    assert(
      imagePaths.length == heroTags.length,
      "imagePaths length must equal heroTags length.",
    );
  }

  @override
  State<SimpleGalleryScreen> createState() => _SimpleGalleryScreenState();
}

class _SimpleGalleryScreenState extends State<SimpleGalleryScreen> {
  late final PageController _pageController = PageController(
    initialPage: widget.initialImageIndex,
  );

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.imagePaths.length,
      itemBuilder: (context, index) {
        final imagePath = widget.imagePaths[index];

        final heroData = HeroData(
          tag: widget.heroTags[index],
          imageRatio:
              widget.initialImageIndex == index
                  ? widget.initialImageRatio
                  : null,
        );

        return DetailImageScreen(imagePath: imagePath, heroData: heroData);
      },
    );
  }
}
