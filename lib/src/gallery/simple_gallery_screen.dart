import 'package:flutter/material.dart';
import 'package:simple_gallery/simple_gallery.dart';

class SimpleGalleryScreen extends StatefulWidget {
  final List<String> imagePaths;

  const SimpleGalleryScreen({super.key, required this.imagePaths});

  @override
  State<SimpleGalleryScreen> createState() => _SimpleGalleryScreenState();
}

class _SimpleGalleryScreenState extends State<SimpleGalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: widget.imagePaths.length,
        itemBuilder: (context, index) {
        final item = widget.imagePaths[index];
      return DetailImageScreen(imagePath: item,);
    });
  }
}
