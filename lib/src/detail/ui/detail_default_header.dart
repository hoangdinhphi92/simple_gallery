import 'package:flutter/material.dart';

class DetailDefaultHeader extends StatelessWidget {
  const DetailDefaultHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.viewPaddingOf(context).top),
        child: Column(
          children: [
            Row(children: [_buildBackButton(context), const Spacer()]),
            Divider(thickness: 1, color: Colors.black12, height: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: Icon(Icons.arrow_back_ios_rounded),
    );
  }
}
