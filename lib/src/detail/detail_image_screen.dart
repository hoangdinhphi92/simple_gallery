import 'package:flutter/material.dart';
import 'package:simple_gallery/src/detail/data/hero_data.dart';
import 'package:simple_gallery/src/detail/zoomable_image_widget.dart';
import 'package:simple_gallery/src/utils/build_context_extension.dart';

typedef DetailImageHeaderBuidler = Widget Function(BuildContext context);
typedef DetailImageFooterBuidler = Widget Function(BuildContext context);

class DetailImageScreen extends StatefulWidget {
  /// List of image file paths to display in the detail view.
  final List<String> imagePaths;

  /// Index of the initially displayed image.
  final int initialImageIndex;

  /// Aspect ratio of the initially displayed image.
  final double initialImageRatio;

  /// Builder for the header widget (e.g., title, close button).
  final DetailImageHeaderBuidler? headerBuilder;

  /// Builder for the footer widget (e.g., captions, controls).
  final DetailImageFooterBuidler? footerBuilder;

  /// Gap between images when swiping in the PageView.
  final double pageGap;

  /// Width of the screen, used for calculating viewport fraction.
  final double screenWidth;

  /// Optional background widget for the detail image screen.
  final Widget? backgroundWidget;

  const DetailImageScreen({
    super.key,
    required this.imagePaths,
    required this.initialImageIndex,
    required this.initialImageRatio,
    required this.screenWidth,
    this.pageGap = 16,
    this.headerBuilder,
    this.footerBuilder,
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
        Positioned(top: 0, left: 0, right: 0, child: _buildHeader(context)),
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

  Widget _buildHeader(BuildContext context) {
    if (widget.headerBuilder != null) {
      return widget.headerBuilder!.call(context);
    }

    return _buildBackButton(context);
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.viewPadding.top),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 48,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
      ),
    );
  }
}
