import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:treasure_mapp/controller.dart';
import 'package:treasure_mapp/manage_place.dart';
import 'package:treasure_mapp/place_dialog.dart';
import 'dbhelper.dart';
import 'place.dart';

void main() {
  runApp(ChangeNotifierProvider<Controller>(
    create: (_) => Controller(),
    child: const MyApp(),
  ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const MainMap(),
        home: const MainMap(),

    );
  }
}

class MainMap extends StatefulWidget {
  const MainMap({Key? key}) : super(key: key);

  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  late DbHelper helper;
  CameraPosition position =
      const CameraPosition(target: LatLng(41.9028, 12.4964), zoom: 12);

  //
  // Future _getCurrentPosition() async {
  //   bool isGeolocationAvailable = await Geolocator.isLocationServiceEnabled();
  //
  //   Position _position = Position(
  //       longitude: position.target.longitude,
  //       latitude: position.target.latitude,
  //       timestamp: DateTime.now(),
  //       accuracy: 1,
  //       altitude: 0,
  //       heading: 0,
  //       speed: 9,
  //       speedAccuracy: 0);
  //   print('not available...................................');
  //   if (isGeolocationAvailable) {
  //     try {
  //       _position = await Geolocator.getCurrentPosition(
  //           desiredAccuracy: LocationAccuracy.best);
  //     } catch (error) {
  //       return _position;
  //     }
  //     print('available...................................');
  //     return _position;
  //   }
  // }
  //
  // List<Marker> markers = [];
  //
  // void addMarker(
  //   Position pos,
  //   String markerId,
  //   String markerTitle,
  // ) {
  //   final marker = Marker(
  //       markerId: MarkerId(markerId),
  //       position: LatLng(pos.latitude, pos.longitude),
  //       infoWindow: InfoWindow(title: markerTitle),
  //       anchor: const Offset(2, 3),
  //       icon: (markerId == 'currpos')
  //           ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
  //           : BitmapDescriptor.defaultMarkerWithHue(
  //               BitmapDescriptor.hueOrange));
  //   markers.add(marker);
  //   setState(() {
  //     markers = markers;
  //   });
  // }
  //
  // Future _getData() async {
  //   await helper.openDb();
  //   List _places = await helper.getPlaces();
  //   for (Place p in _places) {
  //     final pos = Position(
  //         longitude: p.lon,
  //         latitude: p.lat,
  //         timestamp: DateTime.now(),
  //         accuracy: 0,
  //         altitude: 0,
  //         heading: 0,
  //         speed: 0,
  //         speedAccuracy: 0);
  //     addMarker(pos, p.id.toString(), p.name);
  //   }
  //   setState(() {
  //     markers = markers;
  //   });
  // }

  @override
  void initState() {
    helper = DbHelper();
    Provider.of<Controller>(context, listen: false).getPosition().then((pos) {
      Provider.of<Controller>(context, listen: false).addMarker(pos, 'currpos', 'you are here');
      position = CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 12);
    }).catchError((error) {
      print(error.toString());
    });
    //helper.insertData();
    Provider.of<Controller>(context, listen: false).getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Treasure Map'),
        actions: [
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> ManagePlaces()));
          },
              icon: const Icon(Icons.list))
        ],
      ),
      body: Container(
        child: GoogleMap(
          initialCameraPosition: position,
          markers: Set<Marker>.of(Provider.of<Controller>(context).markers),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_location),
        onPressed: () {
          int here = Provider.of<Controller>(context, listen: false).markers
              .indexWhere((p) => p.markerId == const MarkerId('currpos'));
          Place place;
          if (here == -1) {
            place = Place(0, 'name', 0, 0, 'image');
          } else {
            LatLng pos = Provider.of<Controller>(context, listen: false).markers[here].position;
            place = Place(0, '', pos.latitude, pos.longitude, '');
          }
          PlaceDialog dialog = PlaceDialog(place, true);
          showDialog(
              context: context,
              builder: (context) => dialog.buildDialog(context));
        },
      ),
    );
  }
}
