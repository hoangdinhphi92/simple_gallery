import 'package:flutter/material.dart';
import 'dart:async';

import 'package:simple_gallery/simple_gallery.dart';
import 'package:simple_gallery_example/ui/main_route_screen.dart';
import 'package:simple_gallery_example/ui/local_image_gallery.dart';

void main() {
  runApp(
    MaterialApp(home: MainRouteScreen(), debugShowCheckedModeBanner: false),
  );
}
