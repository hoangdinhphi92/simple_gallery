import 'package:flutter/material.dart';
import 'package:simple_gallery_example/ui/custom_image_gallery.dart';
import 'package:simple_gallery_example/ui/local_and_network_gallery.dart';
import 'package:simple_gallery_example/ui/network_image_gallery.dart';
import 'package:simple_gallery_example/ui/local_image_gallery.dart';

enum DestinationScreenType { local, network, both, custom }

class MainRouteScreen extends StatelessWidget {
  const MainRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton(
              context,
              'Local Image Gallery',
              DestinationScreenType.local,
            ),
            _buildButton(
              context,
              'Network Image Gallery',
              DestinationScreenType.network,
            ),
            _buildButton(
              context,
              'Local And Network Image Gallery',
              DestinationScreenType.both,
            ),
            _buildButton(
              context,
              'Custom Image Gallery',
              DestinationScreenType.custom,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String textInput,
    DestinationScreenType screen,
  ) {
    Widget destination = switch (screen) {
      DestinationScreenType.network => NetworkImageGallery(),
      DestinationScreenType.both => LocalAndNetworkImageGallery(),
      DestinationScreenType.local => LocalImageGallery(),
      DestinationScreenType.custom => CustomImageGallery(),
    };

    return Material(
      color: Colors.lightBlue,
      child: InkWell(
        onTap: () => navigateToScreen(context, destination),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            textInput,
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
      ),
    );
  }

  void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
