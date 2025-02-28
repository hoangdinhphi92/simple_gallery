import 'package:flutter/material.dart';

class DetailImageScreen extends StatefulWidget {
  final String imagePath;

  const DetailImageScreen({super.key, required this.imagePath});

  @override
  State<DetailImageScreen> createState() => _DetailImageScreenState();
}

class _DetailImageScreenState extends State<DetailImageScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
