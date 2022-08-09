import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:promociones/utils/options.dart';
import 'package:promociones/pages/home_page.dart';
import 'package:promociones/pages/map_page.dart';
import 'package:promociones/pages/notification_page.dart';
import 'package:promociones/pages/wallet_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TabBarPage extends StatefulWidget {
  TabBarPage({
    Key key,
    this.analytics,
    }): super(key:key);
  final FirebaseAnalytics analytics;
  //final FirebaseAnalyticsObserver observer;
  @override
  TabBarPageState createState() => new TabBarPageState();
}

class TabBarPageState extends State<TabBarPage> {
  HomePage _homePage = new HomePage();
  MapPage _mapPage = new MapPage();
  NotificationPage _notificationPage = new NotificationPage();
  WalletPage _walletPage = new WalletPage();
  List _widgetOptions;
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      _homePage,
      _mapPage,
      _notificationPage,
      _walletPage
    ];
  }

  void _onItemTapped(int index) {
    if(index == 1){
      FirebaseAnalytics.instance.setCurrentScreen(screenName: "Map Page");
    }else if(index == 2){
      FirebaseAnalytics.instance.setCurrentScreen(screenName: "Notification Page");
    }else if(index == 3){
      FirebaseAnalytics.instance.setCurrentScreen(screenName: "Options Page");
    }else{
      FirebaseAnalytics.instance.setCurrentScreen(screenName: "Home Page");
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _showBottomNavAndroid() {
    return SizedBox(
        height: 50.0,
        child: BottomNavigationBar(
          iconSize: 15.0,
          type: BottomNavigationBarType.fixed,
          fixedColor: primaryColor,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.home),
              label:
                'Inicio',

            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.store),
              label:
                'Tiendas',

            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.solidBell),
              label:
                'Notificaciones',

            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_vert),
              label:
                'Mas',

            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      );
  }

  Widget _showBottomNavIos() {
    return BottomNavigationBar(
          iconSize: 15.0,
          type: BottomNavigationBarType.fixed,
          fixedColor: primaryColor,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.home),
              label:
                'Inicio',

            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.store),
              label:
                'Tiendas',

            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.solidBell),
              label:
                'Notificaciones',

            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_vert),
              label:
                'Mas',

            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Theme.of(context).platform == TargetPlatform.android ? _showBottomNavAndroid() : _showBottomNavIos(),
    );
  }
}
