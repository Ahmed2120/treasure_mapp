
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:treasure_mapp/services/dbhelper.dart';
import 'package:treasure_mapp/main.dart';
import 'package:treasure_mapp/model/place.dart';
import 'package:treasure_mapp/screens/main_map_screen.dart';

class PictureScreen extends StatelessWidget {
  final String imagePath;
  final Place place;

  const PictureScreen(this.imagePath, this.place, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DbHelper helper = DbHelper();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Picture'),
        actions: [
          IconButton(
            onPressed: (){
              place.image = imagePath;
              helper.insertPlace(place);
              Navigator.push(context, MaterialPageRoute(builder: (_)=> const MainMap()));
            },
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: Image.file(File(imagePath)),
    );
  }
}
