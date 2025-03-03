import 'package:flutter/material.dart';
import 'package:simple_gallery/src/detail/data/hero_data.dart';
import 'package:simple_gallery/src/detail/zoomable_image_widget.dart';

typedef DetailImageHeaderBuidler = Widget Function(BuildContext context);
typedef DetailImageFooterBuidler = Widget Function(BuildContext context);

class DetailImageScreen extends StatefulWidget {
  final List<String> imagePaths;
  final int initialImageIndex;
  final double initialImageRatio;
  final DetailImageHeaderBuidler? headerBuilder;
  final DetailImageFooterBuidler? footerBuilder;
  final double pageGap;
  final double screenWidth;
  final Widget? backgroundWidget;

  const DetailImageScreen({
    super.key,
    required this.imagePaths,
    required this.initialImageIndex,
    required this.initialImageRatio,
    required this.screenWidth,
    this.headerBuilder,
    this.footerBuilder,
    this.pageGap = 16,
    this.backgroundWidget,
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
        Positioned.fill(child: _buildBackground()),
        Positioned.fill(child: _buildPageView()),
        if (widget.headerBuilder != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: widget.headerBuilder!.call(context),
          ),
        if (widget.footerBuilder != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: widget.footerBuilder!.call(context),
          ),
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

  Widget _buildBackground() {
    return widget.backgroundWidget ?? ColoredBox(color: Colors.white);
  }
}
