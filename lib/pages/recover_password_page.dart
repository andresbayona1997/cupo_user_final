import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/user_service.dart';
import '../utils/widgets/nav_bar.dart';

class RecoverPassword extends StatefulWidget{
  _RecoverPassState createState() => new _RecoverPassState();
}

class _RecoverPassState extends State<RecoverPassword> {
  TextEditingController _email = new TextEditingController(text: null);
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  UserService _userService = new UserService();
  @override
  Widget build(BuildContext context) {
     return Scaffold(
         key: _scaffoldKey,
        appBar: NavBar(
          title: 'Recuperar contraseña',
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              Text("Ingresa el correo asociado a la cuenta de cuponix",
              style: TextStyle(
                fontSize: 20
              ),),
              SizedBox(
                height: 30,
              ),
              TextField(
                controller: _email,
                decoration: InputDecoration(
                    hintText: "ejemplo@gmail.com"
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () async {
                    if (_email.text != null) {
                      await _userService.recoverPassword(_email.text).then((value) {
                        if(value["status"]==200){
                          _showSnackbar('Se ha enviado un correo para la recuperación de la contraseña');
                        }else{
                          _showSnackbar('No se ha encontrado un correo asociado a la cuenta');
                        }
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(148, 3, 123, 1.0),
                      borderRadius: BorderRadius.circular(24)
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text("Recuperar contraseña",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,) ,
                  ),
                ),

              )
            ],
          ),
        ));
  }

  void _showSnackbar(String msg) {
    final snackBar = SnackBar(
      content: Text(
        msg,
        style: TextStyle(fontFamily: 'Raleway'),
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

}