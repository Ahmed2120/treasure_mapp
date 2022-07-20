import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:treasure_mapp/sliding_appbar.dart';

class PhotoScreen extends StatefulWidget {
  final String image;
  final int placeId;
  const PhotoScreen(this.image, this.placeId, {Key? key}) : super(key: key);

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> with SingleTickerProviderStateMixin {
  bool _visible = true;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
      appBar: SlidingAppBar(
        controller: _controller,
        visible: _visible,
        child: AppBar(backgroundColor: Colors.black12,),
      ),
      body: Container(
        child: GestureDetector(
          onTap: () => setState(() => _visible = !_visible),
          child: PhotoView(
            imageProvider: FileImage(
              File(widget.image),
            ),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.contained * 4,
            heroAttributes: PhotoViewHeroAttributes(tag: widget.placeId),
          ),
        ),
    )

    );
  }
}
