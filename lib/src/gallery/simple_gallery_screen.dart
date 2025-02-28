import 'package:flutter/material.dart';

class SimpleGalleryScreen extends StatefulWidget {
  final List<String> imagePaths;

  const SimpleGalleryScreen({super.key, required this.imagePaths});

  @override
  State<SimpleGalleryScreen> createState() => _SimpleGalleryScreenState();
}

class _SimpleGalleryScreenState extends State<SimpleGalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
