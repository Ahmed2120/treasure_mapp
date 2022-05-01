import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:treasure_mapp/camera_screen.dart';
import 'controller.dart';
import 'place.dart';
import 'dbhelper.dart';

class PlaceDialog {
  final txtName = TextEditingController();
  final txtLat = TextEditingController();
  final txtLon = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  String imgCaptured = '';

  final bool isNew;
  final Place place;

  PlaceDialog(this.place, this.isNew);

  Widget buildDialog(BuildContext context) {
    DbHelper helper = DbHelper();
    txtName.text = place.name;
    txtLat.text = place.lat.toString();
    txtLon.text = place.lon.toString();
    return AlertDialog(
      title: const Text('Places'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: txtName,
                decoration: const InputDecoration(hintText: 'Name'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Type valid Name';
                  }
                },
              ),
              TextFormField(
                controller: txtLat,
                decoration: const InputDecoration(hintText: 'Latitude'),
                validator: (val) {
                  if (val!.isEmpty || double.tryParse(val) == null) {
                    return 'Type valid latitude';
                  }
                },
              ),
              TextFormField(
                controller: txtLon,
                decoration: const InputDecoration(hintText: 'Longitude'),
                validator: (val) {
                  if (val!.isEmpty || double.tryParse(val) == null) {
                    return 'Type valid longitude';
                  }
                },
              ),
              Provider.of<Controller>(context).imagePath != null
              ? Container(
                  child: Image.file(File(
                      Provider.of<Controller>(context).imagePath!)))
              :
              (place.image != '')
                      ? Container(child: Image.file(File(place.image)))
                      : Container(),
              IconButton(
                icon: const Icon(Icons.camera_front),
                onPressed: () async {
                  final path = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CameraScreen(place)));
                  imgCaptured = path;
                },
              ),
              ElevatedButton(
                  child: const Text('Ok'),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    FocusScope.of(context).unfocus();
                    _formKey.currentState!.save();
                    place.name = txtName.text;
                    place.lat = double.tryParse(txtLat.text)!;
                    place.lon = double.tryParse(txtLon.text)!;
                    place.image = imgCaptured == '' ? place.image : imgCaptured;
                    isNew
                        ? await helper.insertPlace(place)
                        : await helper.update(place);
                    final pos = Position(
                        longitude: place.lon,
                        latitude: place.lat,
                        timestamp: DateTime.now(),
                        accuracy: 0,
                        altitude: 0,
                        heading: 0,
                        speed: 0,
                        speedAccuracy: 0);
                    // Provider.of<Controller>(context, listen: false).addMarker(pos, placeId.toString(), place.name);
                    Provider.of<Controller>(context, listen: false)
                        .setImgToNull();
                    Provider.of<Controller>(context, listen: false).getData();
                    Navigator.pop(context);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
