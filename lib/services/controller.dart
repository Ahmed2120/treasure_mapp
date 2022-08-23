import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:treasure_mapp/model/place.dart';

import 'dbhelper.dart';

class Controller with ChangeNotifier {
  late DbHelper helper = DbHelper();
  List<Place> places = [];
  final CameraPosition position =
  const CameraPosition(target: LatLng(41.9028, 12.4964), zoom: 12);

  String? _imagePath;

  String? get imagePath {
    return _imagePath;
  }

  void setImg(String path) {
    _imagePath = path;
    notifyListeners();
  }
  void setImgToNull({bool isListen = true}) {
    _imagePath = null;
    if(isListen)notifyListeners();
  }

  Future getPosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    bool isGeolocationAvailable = await Geolocator.isLocationServiceEnabled();

    Position _position = Position(
        longitude: position.target.longitude,
        latitude: position.target.latitude,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 0,
        heading: 0,
        speed: 9,
        speedAccuracy: 0);
    print('not available...................................');
    if (isGeolocationAvailable) {
      try {
        _position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
      } catch (error) {
        return _position;
      }
      print('available...................................');
      return _position;
    }
    notifyListeners();
  }

  getCity(Place place) async{
    final address = await placemarkFromCoordinates(place.lat, place.lon);
    return address.first.administrativeArea;
  }

  List<Marker> markers = [];

  void addMarker(Position pos,
      String markerId,
      String markerTitle,) {
    final marker = Marker(
        markerId: MarkerId(markerId),
        position: LatLng(pos.latitude, pos.longitude),
        infoWindow: InfoWindow(title: markerTitle),
        anchor: const Offset(2, 3),
        icon: (markerId == 'currpos')
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
            : BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange));
    markers.add(marker);

    notifyListeners();
  }

  Future getData() async {
    await helper.openDb();
    markers.removeWhere((element) => element.markerId != MarkerId('currpos'));
    places = await helper.getPlaces();
    for (Place p in places) {
      final pos = Position(
          longitude: p.lon,
          latitude: p.lat,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0);
      addMarker(pos, p.id.toString(), p.name);
    }
    notifyListeners();
  }

  void deleteMarker(int id) {
    int mark = markers.indexWhere((element) =>
    element.markerId == MarkerId(id.toString()));
    markers.removeAt(mark);
    notifyListeners();
  }
}