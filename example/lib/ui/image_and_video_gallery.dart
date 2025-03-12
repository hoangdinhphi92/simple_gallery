import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_gallery/simple_gallery.dart';
import 'package:simple_gallery_example/utils/image_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ImageAndVideoGallery extends StatefulWidget {
  const ImageAndVideoGallery({super.key});

  @override
  State<ImageAndVideoGallery> createState() => _ImageAndVideoGalleryState();
}

class _ImageAndVideoGalleryState extends State<ImageAndVideoGallery> {
  final asset = "assets/video.mp4";

  List<String> listNetworkImages = [
    "https://picsum.photos/id/1001/4912/3264",
    "https://picsum.photos/id/1003/1181/1772",
    "https://picsum.photos/id/1004/4912/3264",
    "https://picsum.photos/id/1005/4912/3264",
  ];

  Uint8List? videoThumbnail;
  late VideoPlayerController controller;

  List<ImageObject> listGalleryObject = [];

  @override
  void initState() {
    super.initState();
    controller =
        VideoPlayerController.asset(asset)
          ..setLooping(true)
          ..initialize().then((_) => controller.play());

    _getThumbnailFromAssets();

    for (var e in listNetworkImages) {
      listGalleryObject.add(ImageObject(type: ImageType.image, path: e));
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SimpleGallery<ImageObject>(
          items: listGalleryObject,
          itemSize:
              (item) =>
                  item.type == ImageType.video
                      ? getImageSizeFromBytes(item.bytes!)
                      : getNetworkImageSize(item.path),
          itemBuilder: (context, item, itemSize, viewSize) {
            final itemType = item.type;
            if (itemType == ImageType.video) {
              return videoThumbnail != null
                  ? Stack(
                    children: [
                      Positioned.fill(
                        child: Image.memory(videoThumbnail!, fit: BoxFit.cover),
                      ),
                      Positioned.fill(
                        child: Icon(Icons.play_circle, color: Colors.black54),
                      ),
                    ],
                  )
                  : CircularProgressIndicator();
            } else {
              return Image.network(
                item.path,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
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
            }
          },
          placeholderBuilder: (context, item) {
            return ColoredBox(
              color: Colors.black38,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          detailDecoration: DetailDecoration(
            placeholderBuilder: (context, item) {
              return ColoredBox(
                color: Colors.black38,
                child: Center(child: CircularProgressIndicator()),
              );
            },
            detailBuilder: (context, item, itemSize, viewSize) {
              final itemType = item.type;
              if (itemType == ImageType.video) {
                return controller.value.isInitialized
                    ? AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    )
                    : Center(child: CircularProgressIndicator());
              } else {
                return Image.network(
                  item.path,
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
              }
            },
            pageGap: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _getThumbnailFromAssets() async {
    final byteData = await rootBundle.load(asset);
    Directory tempDir = await getTemporaryDirectory();

    File tempVideo =
        File("${tempDir.path}$asset")
          ..createSync(recursive: true)
          ..writeAsBytesSync(
            byteData.buffer.asUint8List(
              byteData.offsetInBytes,
              byteData.lengthInBytes,
            ),
          );
    final Uint8List? thumbnail = await VideoThumbnail.thumbnailData(
      video: tempVideo.path,
    );

    if (thumbnail != null) {
      setState(() {
        videoThumbnail = thumbnail;
        listGalleryObject.add(
          ImageObject(type: ImageType.video, path: asset, bytes: thumbnail),
        );
      });
    }
  }
}

enum ImageType { image, video }

class ImageObject {
  final ImageType type;
  final String path;
  final Uint8List? bytes;

  ImageObject({required this.type, required this.path, this.bytes});
}
