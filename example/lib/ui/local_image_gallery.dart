import 'dart:io';
import 'dart:ui' as ui show Codec, FrameInfo, Image, ImmutableBuffer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_gallery/simple_gallery.dart';
import 'package:simple_gallery_example/utils/build_context_extension.dart';
import 'package:simple_gallery_example/utils/image_utils.dart';

const kGridItemPadding = 4.0;
const kCrossAxisCount = 3;

class LocalImageGallery extends StatefulWidget {
  const LocalImageGallery({super.key});

  @override
  State<LocalImageGallery> createState() => _LocalImageGalleryState();
}

class _LocalImageGalleryState extends State<LocalImageGallery> {
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
              crossAxisCount: 5,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.0,
              padding: const EdgeInsets.all(8.0),
              items: imageFiles,
              itemSize: (item) => getLocalImageSize(item),
              itemBuilder: (context, item, itemSize, viewSize) {
                return Image.file(
                  File(item),
                  cacheWidth: viewSize.width.round(),
                  fit: BoxFit.cover,
                  frameBuilder: (
                    context,
                    child,
                    frame,
                    wasSynchronouslyLoaded,
                  ) {
                    if (wasSynchronouslyLoaded || frame != null) {
                      return child;
                    }
                    return Center(
                      child: ColoredBox(
                        color: Colors.black38,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  },
                );
              },
              placeholderBuilder: (context, item) {
                return ColoredBox(
                  color: Colors.black38,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              detailDecoration: DetailDecoration(
                detailBuilder: (context, item, itemSize, viewSize) {
                  return Image.file(
                    File(item),
                    fit: BoxFit.contain,
                    frameBuilder: (
                      context,
                      child,
                      frame,
                      wasSynchronouslyLoaded,
                    ) {
                      if (wasSynchronouslyLoaded || frame != null) {
                        return child;
                      }
                      return Center(
                        child: ColoredBox(
                          color: Colors.black38,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    },
                  );
                },
                placeholderBuilder: (context, item) {
                  return Center(
                    child: ColoredBox(
                      color: Colors.black38,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                },
                pageGap: 16,
                systemUiOverlayStyle: SystemUiOverlayStyle.dark,
                tapToHide: false,
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
