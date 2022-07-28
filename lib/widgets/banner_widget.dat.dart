import 'package:flutter/material.dart';

class ImageBannerWidget extends StatelessWidget {
  ImageBannerWidget({required this.ImageUrl});

  String ImageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      height: 100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10), // Image border
        child: Image.network(
          ImageUrl,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
//--------------------------


