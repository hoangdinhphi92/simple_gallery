# simple_gallery

An easy way to display images as a gallery in full-screen with Hero animation, including pinch, zoom, drag & double tap to zoom.

It also can show any widget instead of an image, such as Container, Text or a SVG.


///.///////
![Simple_Gallery Demo](https://github.com/thesmythgroup/easy_image_viewer/blob/main/demo_images/demo1.gif?raw=true "Simple Gallery Demo")


## Installation

Add `simple_gallery` as a dependency in your pubspec.yaml file.

Import Simple Gallery:
```dart
import 'package:simple_gallery/simple_gallery.dart';
```

## Features

* Show a list of images in GridView (Allow to custom the GridView properties)
* Allow to custom each item in GridView  using `itemBuilder`
* By clicking to GridView item to show each detail image in full-screen in a PageView
* Allow to custom the detail image using `detailDecoration`
* Use pinch & zoom to zoom in and out of images
* Enable to drag up & down the detail image with opacity background to back to GridView with Hero animation
* Allow to scroll with page snap to view each detail image in PageView
* No dependencies besides Flutter
* Fully customizable loading/progress indicator
* Allow double tapping to zoom


## Basic usage

For example, to show several images with paths:

```dark
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimpleGallery<String>(
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
        ),
      ),
    );
  }
```

Note: `itemSize` is the size of image, it is required for Hero animation and cache image.

//////demo


## Show difference type of image

You can use any types for gallery (SimpleGallery<YourType>) and custom the way that the content in both Gridview and PageView is displayed using `itemBuilder` & `detailBuilder`
This example is using NetworkImage:

```dart
  List<NetworkImage> listNetworkImages = [
  const NetworkImage("https://picsum.photos/id/1001/4912/3264"),
  const NetworkImage("https://picsum.photos/id/1003/1181/1772"),
  const NetworkImage("https://picsum.photos/id/1004/4912/3264"),
  const NetworkImage("https://picsum.photos/id/1005/4912/3264")
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimpleGallery<NetworkImage>(
        items: listNetworkImages,
        itemSize: (item) => getImageSize(item),
        itemBuilder: (context, item, itemSize, viewSize) {
          return Image(image: item, fit: BoxFit.cover,);
        },
        detailDecoration: DetailDecoration(
          detailBuilder: (context, item, itemSize, viewSize) {
            return Image(image: item, fit: BoxFit.contain);
          },
          pageGap: 16,
        ),
      ),
    );
  }
```

// result######


## Custom the Gallery

Support you custom the GridView of list images with some properties:

```dart
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SimpleGallery<NetworkImage>(
      items: listNetworkImages,
      itemSize: (item) => getImageSize(item),
      crossAxisCount: 5,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, item, itemSize, viewSize) {
        return Image(image: item, fit: BoxFit.cover,);
      },
      detailDecoration: DetailDecoration(
        detailBuilder: (context, item, itemSize, viewSize) {
          return Image(image: item, fit: BoxFit.contain);
        },
        pageGap: 16,
      ),
    ),
  );
}
```

// result image

Allow to custom each item in Gallery using `itemBuilder` & `detailBuilder`:

```dart
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
            return Stack(
              children: [
                Positioned.fill(child: Image(image: item, fit: BoxFit.cover)),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Icon(Icons.favorite, color: Colors.pink),
                ),
              ],
            );
          },
          detailDecoration: DetailDecoration(
            detailBuilder: (context, item, itemSize, viewSize) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image(image: item, fit: BoxFit.contain),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Icon(Icons.favorite, color: Colors.pink),
                  ),
                ],
              );
            },
            pageGap: 16,
          ),
        ),
      ),
    );
  }
```

## Custom the placeHolder,header & footer in detail screen

Using `detailDecoration` to custom the background,placeHolder,header & footer for detail image in PageView

```dart
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SimpleGallery<NetworkImage>(
      items: listNetworkImages,
      itemSize: (item) => getImageSize(item),
      itemBuilder: (context, item, itemSize, viewSize) {
        return Image(image: item, fit: BoxFit.cover,);
      },
      detailDecoration: DetailDecoration(
        backgroundWidget: ColoredBox(color: Colors.yellow),
        headerBuilder: _buildHeaderDetail,
        footerBuilder: _buildFooterDetail,
        detailBuilder: (context, item, itemSize, viewSize) {
          return Image(image: item, fit: BoxFit.contain);
        },
        pageGap: 16,
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
        style: TextStyle(fontSize: 35, color: Colors.white,),
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
```

