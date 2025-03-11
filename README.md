# simple_gallery

An easy way to display widgets as a gallery in full-screen with Hero animation, including pinch, zoom, drag & double tap to zoom.

It also can show any widgets, such as Image, Container, Text, a SVG or Video,...

## Features

* Show a list of widgets in GridView (Allow to custom the GridView properties)
* Allow to custom each item in GridView  using `itemBuilder`
* By clicking to GridView item to show each detail widget in full-screen in a PageView
* Allow to custom the detail widget using `detailDecoration`
* Use pinch & zoom to zoom in and out of images(widgets)
* Enable to drag up & down the detail widget with opacity background to back to GridView with Hero animation
* Allow to scroll with page snap to view each detail widget in PageView
* Fully customizable loading/progress indicator
* Allow double tapping to zoom
* No dependencies besides Flutter


<p align="center">
<img src="demo_image/app_demo.gif" alt="Simple Gallery Demo" />
</p>


## Installation

Add `simple_gallery` as a dependency in your pubspec.yaml file.

Import Simple Gallery:
```dart
import 'package:simple_gallery/simple_gallery.dart';
```


## Basic usage

For example, to show several images with paths:

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimpleGallery<String>(
        items: imageFiles,
        itemSize: (item) => getImageSize(item),
        placeholderBuilder: (context, item) {
            return ColoredBox(
              color: Colors.black38,
              child: Center(child: CircularProgressIndicator()),
            );
          },
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
          placeholderBuilder: (context, item) {
            return ColoredBox(
              color: Colors.black38,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          pageGap: 16,
        ),
      ),
    );
  }
```

Note: 
> `itemSize` is the size of widget, it is required for Hero animation and cache image.


<p align="center">
<img src="demo_image/basic_usage_demo.gif" alt="Simple Gallery Basic Demo" />
</p>


## Show difference type of widget

You can use any types for gallery (SimpleGallery<YourType>) and custom the way that the content in both Gridview and PageView is displayed using `itemBuilder` & `detailBuilder`
This example is displaying both image and video in gallery:

<p align="center">
<img src="demo_image/image_and_video_gallery_demo.gif" alt="Image & Video Gallery Demo" />
</p>

Or you can replace by any widgets to `itemBuilder` & `detailBuilder`:

<p align="center">
<img src="demo_image/custom_image_demo.gif" alt="Custom widgets Demo" />
</p>

## Custom the Gallery

Support you custom the GridView of list images with some properties:

```dart
   crossAxisCount: 5,
   crossAxisSpacing: 8.0,
   mainAxisSpacing: 8.0,
   childAspectRatio: 1.0,
   padding: const EdgeInsets.all(8.0),
```

<p align="center">
<img src="demo_image/custom_gridview_image.png" alt="Custom Gridview Demo" />
</p>


## Custom the placeHolder,header & footer in detail screen

Using `detailDecoration` with `backgroundWidget`, `headerBuilder` & `footerBuilder` to custom the background, placeHolder, header & footer for detail widget in PageView

<p align="center">
<img src="demo_image/custom_header_footer.gif" alt="Custom Detail Widget Demo" />
</p>


