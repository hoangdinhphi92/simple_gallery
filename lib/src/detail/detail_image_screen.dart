import 'package:flutter/material.dart';
import 'package:simple_gallery/src/detail/data/hero_data.dart';
import 'package:simple_gallery/src/detail/zoomable_image_widget.dart';

class DetailImageScreen extends StatefulWidget {
  final List<String> imagePaths;
  final int initialImageIndex;
  final double initialImageRatio;
  final Widget? header;
  final Widget? footer;
  final double pageGap;
  final double screenWidth;

  const DetailImageScreen({
    super.key,
    required this.imagePaths,
    required this.initialImageIndex,
    required this.initialImageRatio,
    required this.screenWidth,
    this.header,
    this.footer,
    this.pageGap = 16,
  });

  @override
  State<DetailImageScreen> createState() => _DetailImageScreenState();
}

class _DetailImageScreenState extends State<DetailImageScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.initialImageIndex,
      viewportFraction: 1 + (widget.pageGap / widget.screenWidth),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _buildPageView()),
        if (widget.header != null)
          Positioned(top: 0, left: 0, right: 0, child: widget.header!),
        if (widget.footer != null)
          Positioned(bottom: 0, left: 0, right: 0, child: widget.footer!),
      ],
    );
  }

  LayoutBuilder _buildPageView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PageView.builder(
          controller: _pageController,
          itemCount: widget.imagePaths.length,
          itemBuilder: (context, index) {
            final imagePath = widget.imagePaths[index];
            final heroData = HeroData(
              tag: widget.imagePaths[index],
              imageRatio:
                  widget.initialImageIndex == index
                      ? widget.initialImageRatio
                      : null,
            );

            return FractionallySizedBox(
              widthFactor: 1 / _pageController.viewportFraction,
              child: ZoomableImageWidget(
                imagePath: imagePath,
                heroData: heroData,
              ),
            );
          },
        );
      },
    );
  }
}
