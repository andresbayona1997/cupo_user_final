import 'package:flutter/material.dart';
import 'package:promociones/services/auth_service.dart';
import 'package:promociones/services/user_service.dart';
import 'package:promociones/services/storage_service.dart';
import 'package:promociones/utils/widgets/dialog_progress.dart';
import 'package:promociones/utils/validator/validator.dart';


typedef void StringCallback(String val);
typedef void BoolCallback(bool val);
class RegisterEmailMode extends StatefulWidget {
  RegisterEmailMode({this.changeMode, this.loadProgress, this.snackbar});
  final VoidCallback changeMode;
  final BoolCallback loadProgress;
  final StringCallback snackbar;
  _RegisterEmailModeState createState() => new _RegisterEmailModeState();
}

enum MODE {
  PHONE_MODE,
  EMAIL_MODE
}

class _RegisterEmailModeState extends State<RegisterEmailMode> {
  TextEditingController _email;
  TextEditingController _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode _focusEmail = new FocusNode();
  FocusNode _focusPassword = new FocusNode();
  AuthService _authService = new AuthService();
  UserService _userService = new UserService();
  StorageService _storageService  = new StorageService();
  bool _isLoading = false;
  IconData iconPassword = Icons.lock;
  bool obscureText = true;

  @override
  initState() {
    super.initState();
    _email = new TextEditingController(text: null);
    _password = new TextEditingController(text: null);
  }

  @override
  dispose() {
    super.dispose();
  }

  void _validate() {
    if (_validateAndSave()) {
      FocusScope.of(context).requestFocus(FocusNode());
      if (_email.text != null && _email.text.isNotEmpty && _password.text != null && _password.text.isNotEmpty) {
        widget.loadProgress(true);
        _userService.createUser(_email.text, _password.text)
        .then((response) {
          if (response["data"] != null) {
            widget.snackbar('Usuario registrado exitosamente');
            _login(_email.text, _password.text);
            _email.clear();
            _password.clear();
          } else {
            widget.loadProgress(false);
            widget.snackbar(getErrorMsg(response["error"]));
          }
        })
        .catchError((error) {
          widget.loadProgress(false);
          widget.snackbar('Ha ocurrido un error inesperado');
        });
      }
    }
  }

  String getErrorMsg(code) {
    String msg;
    switch(code) {
      case 462:
        msg = "Por favor envia un email valido";
        break;
      case 463:
       msg = "El email ya se encuentra registrado";
       break;
      case 464:
      case 465: 
      default: 
        msg = "Ha ocurrido un error inesperado";  
    }
    return msg;
  } 

  void _login(String username, String password) {
    _authService.signIn(username, password)
    .then((uuid) {
      _userService.login(username, uuid)
      .then((result) {
        if (result != null && result["data"] != null) {
          _storageService.saveValue('token', result["data"]["access_token"]);
          _storageService.saveValue('id', result["data"]["key"]);
          Navigator.pushNamedAndRemoveUntil(context, '/tabs', (Route<dynamic> route) => false);
        }
      })
      .catchError((error) {
        widget.snackbar('Ha ocurrido un error inesperado');
      });
    })
    .catchError((onError) {
      if (onError.code != null) {
        widget.snackbar(onError.code);
      }
    });
  }

  Widget _showBtnChangeMode() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(top: 5.0),
      child: FlatButton(
        onPressed: () => widget.changeMode(),
        child: Text('Registrame con numero de telefono', style: TextStyle(fontSize: 12.0, color: Colors.lightBlue), softWrap: true,),
      ),
    );
  }

  Widget _showForm() {
    return Container(
      child: Form(
        //autovalidate: true,
        key: _formKey,
        child: ListView(
          physics: ScrollPhysics(),  
          shrinkWrap: true,
          children: <Widget>[
            // _showBtnChangeMode(),
            Padding(
              padding: EdgeInsets.only(bottom: 15.0, top: 40.0),
              child: TextFormField(
                focusNode: _focusEmail,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(8.0),
                    ),
                  ),
                  suffixIcon: Icon(Icons.mail_outline, size: 20.0),
                  labelText: 'Email',
                  labelStyle: TextStyle(fontSize: 12.0),
                  errorStyle: TextStyle(fontSize: 10.0),
                ),
                validator: (String val) {
                  if (val.isEmpty) {
                    return 'Este campo es obligatorio';
                 } else if (!Validator.isEmail(val)) {
                    return 'El email es inválido';
                  }
                }
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
              child: TextFormField(
                focusNode: _focusPassword,
                controller: _password,
                obscureText: obscureText,
                decoration: InputDecoration(
                  // icon: Icon(Icons.mail_outline),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(8.0),
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(iconPassword, size: 20.0,),
                    onPressed: () {
                      setState(() => obscureText = !obscureText);
                      if (obscureText) {
                        setState(() {
                          iconPassword = Icons.lock;
                        });
                      } else {
                        setState(() {
                          iconPassword = Icons.no_encryption;
                        });
                      }
                    },
                  ),
                  labelText: 'Password',
                  labelStyle: TextStyle(fontSize: 12.0),
                  errorStyle: TextStyle(fontSize: 10.0)
                ),
                validator: (String val) {
                  if (val.isEmpty) {
                    return 'Este campo es obligatorio';
                  } else if (val.length < 6) {
                    return 'La contraseña debe tener al menos seis caracteres';
                  }
                },
                textInputAction: TextInputAction.done,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 0.0),
              child: ButtonTheme(
                minWidth: MediaQuery.of(context).size.width,
                height: 50.0,
                child: RaisedButton(
                  onPressed: _validate,
                  color: Color.fromRGBO(148, 3, 123, 1.0),
                  child: Text(
                    'Registrarme', 
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Stack(
        children: <Widget>[
          _showForm(),
          DialogProgress(isLoading: _isLoading,)
        ],
      )
    );
  }
}
