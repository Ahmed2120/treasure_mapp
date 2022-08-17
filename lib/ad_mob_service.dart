import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService{
  static String? get bannerAdUnitId{
    if(Platform.isAndroid){
      return 'ca-app-pub-4484070474814455/7435086287';
    }
    else if(Platform.isIOS){
      return '';
    }
    return null;
  }

  static final BannerAdListener bannerListener = BannerAdListener(
    onAdLoaded: (ad)=> debugPrint('ad loaded'),
    onAdFailedToLoad: (ad, error){
      ad.dispose();
      debugPrint('Ad failed to load: $error');
    },
    onAdOpened: (ad)=> debugPrint('ad opened'),
    onAdClosed: (ad)=> debugPrint('ad closed'),
  );
}