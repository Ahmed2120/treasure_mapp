import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:treasure_mapp/services/ad_mob_service.dart';
import 'package:treasure_mapp/services/controller.dart';
import 'package:treasure_mapp/screens/manage_place.dart';
import 'package:treasure_mapp/widgets/place_dialog.dart';
import 'package:treasure_mapp/screens/main_map_screen.dart';
import 'services/dbhelper.dart';
import 'model/place.dart';

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


