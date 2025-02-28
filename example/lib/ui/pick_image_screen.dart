import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_gallery/simple_gallery.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (imageFiles.isNotEmpty)
              Expanded(child: SimpleGalleryScreen(imagePaths: imageFiles)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Sample Gallery'),
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
