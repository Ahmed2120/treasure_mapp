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
        child: Column(
          children: [
            TextField(
              controller: txtName,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            TextField(
              controller: txtLat,
              decoration: const InputDecoration(hintText: 'Latitude'),
            ),
            TextField(
              controller: txtLon,
              decoration: const InputDecoration(hintText: 'Longitude'),
            ),
            (place.image != '')
                ? Container(child: Image.file(File(place.image)))
                : Container(),
            IconButton(
              icon: const Icon(Icons.camera_front),
              onPressed: () {
                if (isNew) {
                  helper.insertPlace(place).then((data) {
                    place.id = data;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CameraScreen(place)));
                  });
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CameraScreen(place)));
                }
              },
            ),
            ElevatedButton(
                child: const Text('Ok'),
                onPressed: () async{
                  place.name = txtName.text;
                  place.lat = double.tryParse(txtLat.text)!;
                  place.lon = double.tryParse(txtLon.text)!;
                  final placeId = await helper.insertPlace(place);
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
                  Provider.of<Controller>(context, listen: false).getData();
                  Navigator.pop(context);
                })
          ],
        ),
      ),
    );
  }
}
