import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:treasure_mapp/screens/photo_screen.dart';
import 'package:treasure_mapp/model/place.dart';

import '../screens/camera_screen.dart';
import '../services/controller.dart';
import '../services/dbhelper.dart';

class PlaceDialog extends StatefulWidget {

  final bool isNew;
  final Place place;
  const PlaceDialog(this.place, this.isNew, {Key? key}) : super(key: key);

  @override
  State<PlaceDialog> createState() => _PlaceDialogState();
}

class _PlaceDialogState extends State<PlaceDialog> {

  final txtName = TextEditingController();
  final txtLat = TextEditingController();
  final txtLon = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  String imgCaptured = '';
  DbHelper helper = DbHelper();
  @override
  void initState() {
    super.initState();
    Provider.of<Controller>(context, listen: false).setImgToNull(isListen: false);

    fillForm();
  }


  fillForm(){
    txtName.text = widget.place.name;
    txtLat.text = widget.place.lat.toString();
    txtLon.text = widget.place.lon.toString();
  }

  @override
  Widget build(BuildContext context) {


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
                      Provider.of<Controller>(context).imagePath!)),
              )
                  :
              (widget.place.image != '')
                  ? Container(
                  child: Image.file(File(
                      widget.place.image))
              )
                  : Container(),
              IconButton(
                icon: const Icon(Icons.camera_front),
                onPressed: () async {
                  final path = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CameraScreen(widget.place)));
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
                    widget.place.name = txtName.text;
                    widget.place.lat = double.tryParse(txtLat.text)!;
                    widget.place.lon = double.tryParse(txtLon.text)!;
                    widget.place.image = imgCaptured == '' ? widget.place.image : imgCaptured;
                    widget.place.city = (await getCity(widget.place))!;
                    widget.isNew
                        ? await helper.insertPlace(widget.place)
                        : await helper.update(widget.place);
                    final pos = Position(
                        longitude: widget.place.lon,
                        latitude: widget.place.lat,
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

  Future<String?>? getCity(Place place) async{
    final address = await placemarkFromCoordinates(place.lat, place.lon);
    return address.first.administrativeArea;
  }

  displayPhoto(String photo, int placeId){
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PhotoScreen(photo, placeId))),
        child: Hero(
          tag: placeId,
          child: Image.file(File(
              photo)),
        )
    );
  }
}
