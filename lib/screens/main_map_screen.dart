import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import '../services/ad_mob_service.dart';
import '../services/controller.dart';
import '../services/dbhelper.dart';
import '../widgets/msg_text.dart';
import 'manage_place.dart';
import '../model/place.dart';
import '../widgets/place_dialog.dart';

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

  bool _isRefused = false;
  String internetMsg = '';
  bool hasInternet = false;
  late StreamSubscription internetCon;

  @override
  void initState() {
    super.initState();
    internetCon = InternetConnectionChecker().onStatusChange.listen((event) {
      final hasInter = event == InternetConnectionStatus.connected;
      print('connected 2: $hasInternet');
      if (hasInter) {
        setState(() {
          _isRefused = false;
          internetMsg = '';
        });}
    else{
        setState(() {
          _isRefused = true;
          internetMsg = 'NO Internet Connection';
        });
      }
      });
    getPosition();
    Provider.of<Controller>(context, listen: false).getData();

    _createBannerAd();
  }

  @override
  void dispose() {
    super.dispose();

    internetCon.cancel();
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
                    MaterialPageRoute(builder: (context) => const ManagePlaces()));
              },
              icon: const Icon(Icons.list))
        ],
      ),
      body: _isRefused ? MsgText(msg: internetMsg) : loader
          ? const Center(child: CircularProgressIndicator())
          : Container(
        child: GoogleMap(
          initialCameraPosition: position,
          markers:
          Set<Marker>.of(Provider.of<Controller>(context).markers),
        ),
      ),
      floatingActionButton: _isRefused ? Container() : Align(
        alignment: const Alignment(0.7, 1),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF827773),
          child: const Icon(Icons.add_location),
          onPressed: () {
            int here = Provider.of<Controller>(context, listen: false)
                .markers
                .indexWhere((p) => p.markerId == const MarkerId('currpos'));
            Place place;
            if (here == -1) {
              place = Place('name', 0, 0, 'image', 'city');
            } else {
              LatLng pos = Provider.of<Controller>(context, listen: false)
                  .markers[here]
                  .position;
              place = Place('', pos.latitude, pos.longitude, '', '');
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