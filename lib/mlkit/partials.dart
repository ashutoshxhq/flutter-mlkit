import 'package:flutter/material.dart';
import 'dart:io';

class ImageWidget extends StatelessWidget {
  ImageWidget(this.file);
  final File file;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
      height: 100.0,
      width: 150.0,
      child: file == null ?
      new Text('Sorry nothing selected!!') :
      new Image.file(file),
    ),
    );
  }
}

class TabItem extends StatelessWidget {
  final String title;
  TabItem(this.title);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16
        )
      ),
    );
  }
}