import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:promociones/pages/my_profile_page.dart';
import 'package:promociones/services/user_service.dart';
import 'package:promociones/utils/widgets/nav_bar.dart';
import 'package:promociones/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:promociones/utils/globals.dart';


class WalletPage extends StatefulWidget {
  @override
  _WalletStatePage createState() => new _WalletStatePage();
}

class _WalletStatePage extends State<WalletPage> {
  AuthService _authService = new AuthService();
  FlutterSecureStorage storage = new FlutterSecureStorage();
  UserService _userService = new UserService();
  List options = [
    {
      "title": "Mis promociones redimidas",
      "icon": new Icon(
        Icons.star_border,
        color: Colors.grey,
      ),
      "route": "/reedemPromotions"
    },
    {
      "title": "Mis direcciones",
      "icon": new Icon(
        Icons.room_outlined,
        color: Colors.grey,
      ),
      "route": "/directions"
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  signOut() async {
    try {
      _userService.logout().then((result) {
        if (result != null && result["status"] == 200) {
          _authService.signOut();
          storage.deleteAll();
          navigatorKey.currentState.pushReplacementNamed('/root');
        }
      });
    } catch (e) {
      print('SignuotError $e');
    }
  }

  void _onTapped(String route) {

    print('Options $route');
    if (route != null) {
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: NavBar(
          title: 'Mas',
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[_showHeader(), _showListOptions(), logout()],
          ),
        ));
  }

  Widget logout() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: FlatButton(
          child: Text(
            'Cerrar sesión',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: signOut,
        ),
      ),
    );
  }

  Widget _showHeader() {
    return new Container(
      color: new Color.fromRGBO(180, 3, 123, 1.0),
      padding: new EdgeInsets.all(20.0),
      height: 150.0,
      child: Row(
        children: <Widget>[
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Expanded(
                  child: new Text(
                    'Mi perfil',
                    style: new TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 24.0),
                  ),
                ),
                new Expanded(
                    child: new Padding(
                  padding: new EdgeInsets.only(left: 12.0),
                  child: new Text(
                    'Encuentra aquí la información de tu perfil',
                    style: new TextStyle(color: Colors.white, fontSize: 12.0),
                    textAlign: TextAlign.center,
                  ),
                )),
                new Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: TextButton(
                        onPressed: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MyProfilePage())
                          );
                        },
                        child: new Text(
                          'Ver mi perfil',
                          style: new TextStyle(
                              color: new Color.fromRGBO(180, 3, 123, 1.0),
                              fontFamily: 'Raleway',
                              fontSize: 13.0),
                        ),
                      ),
                    ))
              ],
            ),
          ),
          new Expanded(
              child: new Padding(
            padding: new EdgeInsets.all(10.0),
            child: new Center(
              child: new Icon (
                Icons.supervised_user_circle,
                color: Colors.white,
                size: 90,
              )
            ),
          ))
        ],
      ),
    );
  }

  Widget _showListOptions() {
    return ListView.separated(
        // padding: EdgeInsets.all(0.0),
        physics: ScrollPhysics(),
        shrinkWrap: true,
        itemCount: options.length,
        separatorBuilder: (BuildContext context, int index) => Divider(
              height: 0.0,
            ),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            splashFactory: InkRipple.splashFactory,
            onTap: (){
              FirebaseAnalytics.instance.setCurrentScreen(screenName: options[index]["title"]);
              _onTapped(options[index]["route"]);},
            child: Container(
              child: Row(
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.all(20.0),
                    child: options[index]["icon"],
                  ),
                  new Padding(
                    padding: new EdgeInsets.only(left: 15.0),
                    child: new Align(
                      child: new Text(options[index]["title"],
                          style: new TextStyle(
                              color: new Color.fromRGBO(180, 3, 123, 1.0))),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  new Expanded(
                    child: Container(
                      width: 120.0,
                      child: Padding(
                        padding: new EdgeInsets.all(15.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: new Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 15.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
