import 'package:flutter/material.dart';

class ChooseModePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromRGBO(148, 3, 123, 1.0),
            Color.fromRGBO(191, 111, 178, 1.0)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Stack(children: [
          Container(
            child: Center(
              child: Image.asset(
                'assets/cuponix.png',
                height: 150.0,
                width: 150.0,
              ),
            ),
          ),
          Positioned(
            bottom: 20.0,
            left: 15.0,
            right: 15.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: ButtonTheme(
                    height: 40.0,
                    buttonColor: Colors.white,
                    child: RaisedButton(
                      textColor: Color.fromRGBO(148, 3, 123, 1.0),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      child: Text(
                        'Iniciar sesión',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(18.0))),
                    ),
                  ),
                )),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: ButtonTheme(
                    height: 40.0,
                    child: RaisedButton(
                      color: Color.fromRGBO(148, 3, 123, 1.0),
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                      child: Text(
                        'Registrarse',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(18.0))),
                    ),
                  ),
                )),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
