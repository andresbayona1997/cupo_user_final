//import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promociones/app_config.dart';
import 'package:promociones/pages/directions_page.dart';
import 'package:promociones/pages/login_page.dart';
import 'package:promociones/pages/recover_password_page.dart';
import 'package:promociones/pages/register_page.dart';
import 'package:promociones/pages/root_page.dart';
import 'package:promociones/pages/my_profile_page.dart';
import 'package:promociones/pages/detail_promotion_page.dart';
import 'package:promociones/pages/reedemed_promotions_page.dart';
import 'package:promociones/pages/select_products_page.dart';
import 'package:promociones/pages/tab_bar_page.dart';
import 'package:promociones/pages/terms_and_conditions_page.dart';
import 'package:promociones/utils/globals.dart';




Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseAnalytics.instance.setCurrentScreen(screenName: "Home page");
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  //FirebaseCrashlytics.instance.crash();
  final FirebaseMessaging _firebaseMessaging =  FirebaseMessaging.instance;

  final token = await _firebaseMessaging.getToken();
  print(token);
  // _firebaseMessaging.configure(
  //   onBackgroundMessage: ()
  // );
  //Crashlytics.instance.enableInDevMode = true;
  //Crashlytics.instance.crash();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);




  const MethodChannel('flavor')
      .invokeMethod<String>('getFlavor')
      .then((String flavor) {
        print("THIS IS THE FLAVOR $flavor");
    if (flavor == 'production') {
      startProduction();
    } else if (flavor == 'qa') {
      startQA();
    }
  }).catchError((error) {
    //print(error);
    print('FAILED TO LOAD FLAVOR => initializing qa by default');
    startQA();
  });
  runApp(MyApp(analytics: analytics,));
}

void startProduction() {
  AppConfig.getInstance(
      appName: 'Cuponix',
      flavorName: 'production',
      apiBaseUrl: 'api-dot-activaciones.appspot.com');
}

void startQA() {
  AppConfig.getInstance(
      appName: 'Cuponix QA',
      flavorName: 'qa',
      apiBaseUrl: 'test-cuponix-dot-activaciones.uc.r.appspot.com');
}

class MyApp extends StatelessWidget {

  MyApp({
  this.analytics});
  final FirebaseAnalytics analytics;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuponix',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Raleway',
        primarySwatch: Colors.purple,
      ),
      //navigatorObservers: <NavigatorObserver>[observer],
      home: RootPage(init: true),
      routes: {
        '/root': (context) => RootPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/tabs': (context) => TabBarPage(analytics: analytics,),
        '/myProfile': (context) => MyProfilePage(),
        '/detailsPromotion': (context) => DetailPromotionPage(),
        '/reedemPromotions': (context) => ReedemedPromotionPage(),
        '/terms': (context) => TermsAndConditionsPage(),
        '/selectProducts': (context) => SelectProductsPage(),
        '/directions': (context) => MyDirectionPage(),
        "/passRec":(BuildContext context) => RecoverPassword()
      },
    );
  }
}
