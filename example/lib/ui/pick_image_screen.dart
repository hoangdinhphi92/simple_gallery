import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_gallery/simple_gallery.dart';
import 'package:simple_gallery_example/utils/build_context_extension.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SimpleGalleryScreen(
                imagePaths: imageFiles,
                padding: EdgeInsets.symmetric(horizontal: 4),
                detailImageHeaderBuilder: (context) {
                  return _buildDetailImageHeader(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailImageHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.viewPadding.top),
      child: SizedBox(
        height: 48,
        child: Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
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
