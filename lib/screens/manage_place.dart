import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:treasure_mapp/screens/photo_screen.dart';
import 'package:treasure_mapp/model/place.dart';
import '../services/ad_mob_service.dart';
import '../services/controller.dart';
import '../widgets/place_dialog.dart';
import '../services/dbhelper.dart';
import 'package:geocoding/geocoding.dart';

import '../widgets/place_item.dart';


class ManagePlaces extends StatefulWidget {
  const ManagePlaces({Key? key}) : super(key: key);

  @override
  State<ManagePlaces> createState() => _ManagePlacesState();
}

class _ManagePlacesState extends State<ManagePlaces> {

  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();

    _createBannerAd();
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
        title: const Text('Manage Places'),
      ),
      body: const PlaceList(),
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

class PlaceList extends StatefulWidget {
  const PlaceList({Key? key}) : super(key: key);

  @override
  _PlaceListState createState() => _PlaceListState();
}

class _PlaceListState extends State<PlaceList> {

  DbHelper helper = DbHelper();



  getCity(Place place) async{
    final address = await placemarkFromCoordinates(place.lat, place.lon);
    return address.first.administrativeArea;
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<Controller>(
      builder: (context, controller, _)=>
          controller.places.isEmpty ?
              Center(
                child: Text('No Places Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: const Color(0xFF827773).withOpacity(0.7))),
              ):
          ListView.builder(
        itemCount: controller.places.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(controller.places[index].id.toString()),
            background: Container(
              color: Theme.of(context).errorColor,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 40,
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) {
              return showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Are you sre?'),
                    content: const Text('You want to delete this place'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('No')),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Yes')),
                    ],
                  ));
            },
            onDismissed: (direction)async{
              print('city: ${await getCity(controller.places[index])}');
              String strName = controller.places[index].name;
              Provider.of<Controller>(context, listen: false).deleteMarker(controller.places[index].id!);
              helper.deletePlace(controller.places[index]);

              setState(() {
                controller.places.removeAt(index);
              });
              Provider.of<Controller>(context, listen: false).getData();
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$strName deleted", textAlign: TextAlign.center,), duration: Duration(milliseconds: 500),));
            },
            child: PlaceItem(place: controller.places[index],),
          );
        },
      ),
    );
  }
}

