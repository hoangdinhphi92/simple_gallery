import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_gallery/simple_gallery.dart';
import 'package:simple_gallery_example/utils/build_context_extension.dart';
import 'package:simple_gallery_example/utils/image_utils.dart';

class LocalAndNetworkImageGallery extends StatefulWidget {
  const LocalAndNetworkImageGallery({super.key});

  @override
  State<LocalAndNetworkImageGallery> createState() =>
      _LocalAndNetworkImageGalleryState();
}

class _LocalAndNetworkImageGalleryState
    extends State<LocalAndNetworkImageGallery> {
  List<ImageObject> listImageObject = [];

  @override
  void initState() {
    super.initState();
    for (var e in listNetworkImages) {
      listImageObject.add(ImageObject(ImageType.network, e.url.toString()));
    }
  }

  void _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        listImageObject.clear();
        // imageFiles = pickedFiles.map((e) => e.path).toList();
        List<String> imageFromLocal = pickedFiles.map((e) => e.path).toList();

        for (var e in imageFromLocal) {
          listImageObject.add(ImageObject(ImageType.local, e));
        }
        for (var e in listNetworkImages) {
          listImageObject.add(ImageObject(ImageType.network, e.url.toString()));
        }
      });
    }
  }

  List<NetworkImage> listNetworkImages = [
    const NetworkImage("https://picsum.photos/id/1001/4912/3264"),
    const NetworkImage("https://picsum.photos/id/1003/1181/1772"),
    const NetworkImage("https://picsum.photos/id/1004/4912/3264"),
    const NetworkImage("https://picsum.photos/id/1005/4912/3264"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: context.viewPadding.top),
          _buildHeader(),
          Expanded(
            child: SimpleGallery<ImageObject>(
              items: listImageObject,
              itemSize:
                  (item) =>
                      item.imageType == ImageType.local
                          ? getLocalImageSize(item.imagePath)
                          : getNetworkImageSize(item.imagePath),
              itemBuilder: (context, item, itemSize, viewSize) {
                final itemType = item.imageType;
                if (itemType == ImageType.local) {
                  return Image.file(
                    File(item.imagePath),
                    cacheWidth: viewSize.width.round(),
                    fit: BoxFit.cover,
                  );
                } else {
                  return Image.network(item.imagePath, fit: BoxFit.cover,);
                }
              },
              detailDecoration: DetailDecoration(
                detailBuilder: (context, item, itemSize, viewSize) {
                  final itemType = item.imageType;
                  if (itemType == ImageType.local) {
                    return Image.file(File(item.imagePath), fit: BoxFit.contain);
                  } else {
                    return Image.network(item.imagePath, fit: BoxFit.contain);
                  }
                },
                pageGap: 16,
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

enum ImageType { local, network }

class ImageObject {
  final ImageType imageType;
  final String imagePath;

  ImageObject(this.imageType, this.imagePath);
}
