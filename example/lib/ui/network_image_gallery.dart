import 'package:flutter/material.dart';
import 'package:simple_gallery/simple_gallery.dart';

import '../utils/image_utils.dart';

class NetworkImageGallery extends StatefulWidget {
  const NetworkImageGallery({super.key});

  @override
  State<NetworkImageGallery> createState() => _NetworkImageGalleryState();
}

class _NetworkImageGalleryState extends State<NetworkImageGallery> {
  List<NetworkImage> listNetworkImages = [
    const NetworkImage("https://picsum.photos/id/1001/4912/3264"),
    const NetworkImage("https://picsum.photos/id/1003/1181/1772"),
    const NetworkImage("https://picsum.photos/id/1004/4912/3264"),
    const NetworkImage("https://picsum.photos/id/1005/4912/3264"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SimpleGallery<NetworkImage>(
          items: listNetworkImages,
          itemSize: (item) => getNetworkImageSize(item.url.toString()),
          itemBuilder: (context, item, itemSize, viewSize) {
            return Image(
              image: item,
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
          },
          placeholderBuilder: (context, item) {
            return ColoredBox(
              color: Colors.black38,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          detailDecoration: DetailDecoration(
            backgroundWidget: ColoredBox(color: Colors.yellow),
            headerBuilder: _buildHeaderDetail,
            footerBuilder: _buildFooterDetail,
            detailBuilder: (context, item, itemSize, viewSize) {
              return Image(
                image: item,
                fit: BoxFit.contain,
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
            },
            pageGap: 16,
            placeholderBuilder: (context, item) {
              return ColoredBox(
                color: Colors.black38,
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFooterDetail(BuildContext context, NetworkImage image) {
    return ColoredBox(
      color: Colors.red,
      child: Center(
        child: Text(
          'This is Footer',
          style: TextStyle(fontSize: 35, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeaderDetail(BuildContext context, NetworkImage image) {
    return ColoredBox(
      color: Colors.red,
      child: Column(
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back),
          ),
          Expanded(
            child: Text(
              'This is Header',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
