// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// class BannerAdWidget extends StatefulWidget {
//   @override
//   _BannerAdWidgetState createState() => _BannerAdWidgetState();
// }
//
// class _BannerAdWidgetState extends State<BannerAdWidget> {
//   late BannerAd _bannerAd;
//
//   @override
//   void initState() {
//     super.initState();
//     _bannerAd = BannerAd(
//       adUnitId: 'YOUR_AD_UNIT_ID', // Replace with your own ad unit ID
//       size: AdSize.banner,
//       request: AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (Ad ad) {
//           print('Ad loaded: $ad');
//         },
//         onAdFailedToLoad: (Ad ad, LoadAdError error) {
//           ad.dispose();
//           print('Ad failed to load: $error');
//         },
//       ),
//     );
//     _bannerAd.load();
//   }
//
//   @override
//   void dispose() {
//     _bannerAd.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       child: AdWidget(ad: _bannerAd),
//       width: _bannerAd.size.width.toDouble(),
//       height: _bannerAd.size.height.toDouble(),
//     );
//   }
// }