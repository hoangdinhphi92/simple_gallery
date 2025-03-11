import 'dart:io';
import 'dart:ui' as ui show Codec, FrameInfo, Image, ImmutableBuffer;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_gallery/simple_gallery.dart';
import 'package:simple_gallery_example/utils/build_context_extension.dart';
import 'package:simple_gallery_example/utils/image_utils.dart';

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
      body: Column(
        children: [
          SizedBox(height: context.viewPadding.top),
          _buildHeader(),
          Expanded(
            child: SimpleGallery<String>(
              items: imageFiles,
              itemSize: (item) => getImageSize(item),
              itemBuilder: (context, item, itemSize, viewSize) {
                return Image.file(
                  File(item),
                  cacheWidth: viewSize.width.round(),
                  fit: BoxFit.cover,
                );
              },
              detailDecoration: DetailDecoration(
                detailBuilder: (context, item, itemSize, viewSize) {
                  return Image.file(File(item), fit: BoxFit.contain);
                },
                pageGap: 16,
                // footerBuilder: (context, items, item, pageController) {
                //   return Text("data");
                // },
              ),
            ),
          ),
        ],
      ),
    );
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
}
