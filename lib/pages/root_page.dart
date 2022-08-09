import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:promociones/enums/auth_status_enum.dart';
import 'package:promociones/pages/choose_mode_page.dart';
import 'package:promociones/pages/login_signup_page.dart';
import 'package:promociones/pages/tab_bar_page.dart';
import 'package:promociones/services/auth_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:promociones/pages/notification_page.dart';
import 'package:flutter/cupertino.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class RootPage extends StatefulWidget {
  RootPage({this.init});
  final bool init;
  @override
  RootPageState createState() => new RootPageState();
}

class RootPageState extends State<RootPage> {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AuthStatusEnum authStatus = AuthStatusEnum.NOT_DETERMINED;
  String _userId = "";
  AuthService _authSrv = new AuthService();
  DatabaseReference _notificationRef;
  StreamSubscription<Event> _notificationsSubscription;

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    // _notificationsSubscription = _notificationRef.onValue.listen((Event event) {
    //   _showNotification(event);
    // });

    _authSrv.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
          FirebaseDatabase.instance
              .reference()
              .child('messages/$_userId')
              .onChildAdded
              .listen((Event data) {
            if (data.snapshot.value["unix_timestamp"] != null) {
              DateTime notification = new DateTime.fromMillisecondsSinceEpoch(
                  data.snapshot.value["unix_timestamp"] * 1000);
              DateTime today = new DateTime.now();
              if (today.hour - notification.hour == 0) {
                _showNotification(data);
              }
            }
          });
          // _notificationsSubscription = _notificationRef.onChildAdded.listen((Event event) {
          //   print('Event ${event.snapshot.value}');
          //   _showNotification(event);
          // });
        }
        authStatus = user?.uid == null
            ? AuthStatusEnum.NOT_LOGGED_IN
            : AuthStatusEnum.LOGGED_IN;
      });
    });
  }

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationPage()),
    );
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPage(),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Future<void> _showNotification(Event event) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'Promoción redimida',
        'Has redimido la promoción correctamente', platformChannelSpecifics,
        payload: 'item x');
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: SpinKitThreeBounce(
          color: Color.fromRGBO(148, 3, 123, 1.0),
          size: 30.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatusEnum.NOT_DETERMINED:
      case AuthStatusEnum.NOT_LOGGED_IN:
        return ChooseModePage();
        break;
      case AuthStatusEnum.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return TabBarPage();
        } else
          return _buildWaitingScreen();
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}
