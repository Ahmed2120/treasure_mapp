import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:treasure_mapp/ad_mob_service.dart';
import 'package:treasure_mapp/controller.dart';
import 'package:treasure_mapp/manage_place.dart';
import 'package:treasure_mapp/place_dialog.dart';
import 'dbhelper.dart';
import 'place.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(
    ChangeNotifierProvider<Controller>(
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
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF827773),
        ),
        // primarySwatch: Colors.blue,
        primaryColor: Color(0xFF827773),
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

  bool loader = false;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    getPosition();
    Provider.of<Controller>(context, listen: false).getData();

    _createBannerAd();
  }

  void getPosition() {
    helper = DbHelper();
    setState(() {
      loader = true;
    });
    Provider.of<Controller>(context, listen: false).getPosition().then((pos) {
      Provider.of<Controller>(context, listen: false)
          .addMarker(pos, 'currpos', 'you are here');
      position =
          CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 12);
      setState(() {
        loader = false;
      });
      print('${position}');
    }).catchError((error) {
      print(error.toString());
    });
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdMobService.bannerAdUnitId!,
        listener: AdMobService.bannerListener,
        request: const AdRequest())
      ..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Treasure Map'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ManagePlaces()));
              },
              icon: const Icon(Icons.list))
        ],
      ),
      body: loader
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: GoogleMap(
                initialCameraPosition: position,
                markers:
                    Set<Marker>.of(Provider.of<Controller>(context).markers),
              ),
            ),
      floatingActionButton: Align(
        alignment: Alignment(0.7, 1),
        child: FloatingActionButton(
          backgroundColor: Color(0xFF827773),
          child: const Icon(Icons.add_location),
          onPressed: () {
            int here = Provider.of<Controller>(context, listen: false)
                .markers
                .indexWhere((p) => p.markerId == const MarkerId('currpos'));
            Place place;
            if (here == -1) {
              place = Place('name', 0, 0, 'image');
            } else {
              LatLng pos = Provider.of<Controller>(context, listen: false)
                  .markers[here]
                  .position;
              place = Place('', pos.latitude, pos.longitude, '');
            }
            PlaceDialog dialog = PlaceDialog(place, true);
            showDialog(
                context: context,
                builder: (context) => PlaceDialog(place, true));
          },
        ),
      ),
      bottomNavigationBar: _bannerAd == null
          ? Container(height: 0,)
          : Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 52,
              child: AdWidget(
                ad: _bannerAd!,
              ),
            ),
    );
  }
}
