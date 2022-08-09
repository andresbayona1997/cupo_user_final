import 'package:flutter/material.dart';
import 'package:promociones/config.dart';
import 'package:promociones/services/auth_service.dart';
import 'package:promociones/services/storage_service.dart';
import 'package:promociones/services/user_service.dart';
import 'package:promociones/utils/widgets/dialog_progress.dart';
import 'package:promociones/utils/classes/auth_errors.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => new _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  TextEditingController _email = new TextEditingController(text: null);
  TextEditingController _password = new TextEditingController(text: null);
  bool _isLoading = false;
  AuthService _authService = new AuthService();
  UserService _userService = new UserService();
  StorageService _storageService = new StorageService();
  String _errorMessage = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _validate() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_email.text != null &&
        _email.text.length > 0 &&
        _password.text != null &&
        _password.text.length > 0) {
      setState(() => _isLoading = true);
      _authService.signIn(_email.text, _password.text).then((uuid) {
        if (uuid != null) {
          _userService.login(_email.text, uuid).then((value) {
            setState(() {
              _isLoading = false;
            });
            if (value != null &&
                value["data"] != null &&
                value["data"]["role_name"] == ROLE) {
              _storageService.saveValue('token', value["data"]["access_token"]);
              _storageService.saveValue('id', value["data"]["key"]);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/tabs', (Route<dynamic> route) => false);
            } else {
              _showSnackbar('Acceso denegado');
            }
          }).catchError((onError) {
            _showSnackbar('Ha ocurrido un error inesperado');
          });
        }
      }).catchError((error) {
        print(error);
        setState(() {
          _isLoading = false;

          if (error.code != null) {
            _errorMessage = AuthErrors.getErrorMsg(error.code);
            _showSnackbar(_errorMessage);
          }
        });
      });
    }
  }

  void _showSnackbar(String msg) {
    final snackBar = SnackBar(
      content: Text(
        msg,
        style: TextStyle(fontFamily: 'Raleway'),
      ),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {},
        textColor: Colors.white,
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Widget _showIcon() {
    return Container(
        padding: EdgeInsets.all(30.0),
        child: Center(
          child: Image.asset(
            'assets/customer.png',
            height: 130.0,
          ),
        ));
  }

  Widget _showForm() {
    return Container(
      child: Form(
        child: ListView(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 30.0, top: 5.0),
              child: TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    // icon: Icon(Icons.mail_outline),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(8.0),
                      ),
                    ),
                    suffixIcon: Icon(
                      Icons.mail_outline,
                      size: 20.0,
                    ),
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: 13.0)
                    // border:
                    ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(
                      // icon: Icon(Icons.mail_outline),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(8.0),
                        ),
                      ),
                      suffixIcon: Icon(
                        Icons.lock,
                        size: 20.0,
                      ),
                      labelText: 'Password',
                      labelStyle: TextStyle(fontSize: 13.0))),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 25.0),
              child: ButtonTheme(
                minWidth: MediaQuery.of(context).size.width,
                height: 50.0,
                child: RaisedButton(
                  onPressed: _validate,
                  color: Color.fromRGBO(148, 3, 123, 1.0),
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry paddingCard =
        Theme.of(context).platform == TargetPlatform.android
            ? EdgeInsets.only(top: 15.0, bottom: 40.0, left: 20.0, right: 20.0)
            : EdgeInsets.only(top: 15.0, bottom: 60.0, left: 20.0, right: 20.0);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(148, 3, 123, 1.0),
        elevation: 0.0,
        title: Text('Iniciar sesión',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17.0)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close),
        ),
        // iconTheme: IconThemeData(opacity: 0.1),
      ),
      body: Stack(
        children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color.fromRGBO(148, 3, 123, 1.0),
                  Color.fromRGBO(191, 111, 178, 1.0)
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  margin: paddingCard,
                  child: ListView(
                    padding: EdgeInsets.all(20.0),
                    shrinkWrap: true,
                    children: <Widget>[_showIcon(), _showForm()],
                  ),
                ),
              )),
          // _showBody(),
          DialogProgress(
            isLoading: _isLoading,
          )
        ],
      ),
    );
  }
}
