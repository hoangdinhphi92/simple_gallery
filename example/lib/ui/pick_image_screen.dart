import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_gallery_example/ui/example_gallery_screen.dart';
import 'package:simple_gallery_example/utils/buildcontext_extension.dart';

const kGridItemPadding = 4.0;
const kCrossAxisCount = 3;

class PickImageScreen extends StatefulWidget {
  const PickImageScreen({super.key});

  @override
  State<PickImageScreen> createState() => _PickImageScreenState();
}

class _PickImageScreenState extends State<PickImageScreen> {
  List<String> imageFiles = [];

  void _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      imageFiles.clear();

      setState(() {
        imageFiles = pickedFiles.map((e) => e.path).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (imageFiles.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: imageFiles.length,
                  padding: EdgeInsets.all(kGridItemPadding),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: kCrossAxisCount,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: kGridItemPadding,
                    mainAxisSpacing: kGridItemPadding,
                  ),
                  itemBuilder: (context, index) {
                    final imagePath = imageFiles[index];
                    return _buildGridItem(context, imagePath, index);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  final Map<String, double> _imageRatioMap = {};

  GestureDetector _buildGridItem(
    BuildContext context,
    String imagePath,
    int index,
  ) {
    final imageProvider = ResizeImage.resizeIfNeeded(
      ((context.viewSize.width / kCrossAxisCount) * context.devicePixelRatio)
          .toInt(),
      null,
      FileImage(File(imagePath)),
    );

    _getImageSize(imageProvider, imagePath);
    return GestureDetector(
      onTap: () => _navigateToSimpleGallery(context, index, imagePath),
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

  Widget _buildHeader() {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          const SizedBox(width: 16),
          Text('Sample Gallery'),
          const Spacer(),
          IconButton(
            onPressed: () {
              _pickImages();
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _navigateToSimpleGallery(
    BuildContext context,
    int index,
    String imagePath,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, animation, secondaryAnimation) {
          return ExampleGalleryScreen(
            imagePaths: imageFiles,
            initialImageIndex: index,
            initialImageRatio: _imageRatioMap[imagePath]!,
            heroTags: imageFiles,
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
