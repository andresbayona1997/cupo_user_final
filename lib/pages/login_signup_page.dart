import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:promociones/enums/form_mode_enum.dart';
import 'package:promociones/utils/validator/validator.dart';
import 'package:promociones/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:promociones/services/user_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:promociones/utils/options.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:promociones/utils/widgets/dialog_circular_progress.dart';
import 'package:promociones/utils/classes/auth_errors.dart';
import 'package:promociones/utils/formatters/phone_formatter.dart';
import 'package:promociones/utils/widgets/nav_bar.dart';

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({this.onSignedIn});
  final VoidCallback onSignedIn;
  @override
  LoginSignUpPageState createState() => new LoginSignUpPageState();
}

class LoginSignUpPageState extends State<LoginSignUpPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final storage = new FlutterSecureStorage();
  final _formKey = new GlobalKey<FormState>();
  FormModeEnum _formMode = FormModeEnum.LOGIN;
  TextEditingController _email = new TextEditingController(text: null);
  TextEditingController _password = new TextEditingController(text: null);
  TextEditingController _phoneNumber = new TextEditingController(text: null);
  TextEditingController _smsController = TextEditingController();
  AuthService _authSrv = new AuthService();
  UserService _userSrv = new UserService();
  bool _isLoading;
  String _errorMessage = '';
  bool backendResult = false;
  bool _isActiveSwitch = false;
  String _message = '';
  String _verificationId;
  String _smsCode;
  AuthErrors _authErrors = new AuthErrors();

  final _mobileFormatter = NumberTextInputFormatter();
  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _errorMessage = "";
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormModeEnum.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormModeEnum.LOGIN;
    });
  }

  void saveData(user) async {
    print('Saving token ${user["access_token"]}');
    await storage.write(key: 'token', value: user["access_token"]);
    await storage.write(key: 'id', value: user["key"]);
  }
  
  void _validateAndSubmit() async {
    if (_validateAndSave()) {
      String userId = "";
      setState(() => _isLoading = true);
      try {
        if (_isActiveSwitch) {
          _verifyPhoneNumber();
        } else {
          if (_formMode == FormModeEnum.LOGIN) {
            print('${_email.text} ${_password.text}');
            await _authSrv.signIn(_email.text, _password.text)
            .then((userid) {
              userId = userid;
              print('Signed in: $userId');              
              if (userId.length > 0) {
                signInBack(_email.text, userId);
              }
            });
          } else {
            await _authSrv.signUp(_email.text, _password.text)
            .then((user) {
              print(user);
              userId = user.uid;
              if (userId.length > 0) {
                signUpBack(_email.text, userId);
              } 
            });
          }
        }
        setState(() {
          _isLoading = false;
        });

        // if (userId.length > 0 && userId != null && _formMode == FormModeEnum.LOGIN && backendResult) {
        //   widget.onSignedIn();
        // }

      } catch (e) {
        // print(e);
        // print('Error: ${e.code} ${e.message}');
        setState(() {
          _isLoading = false;
          if (e.code != null) {
            _errorMessage = AuthErrors.getErrorMsg(e.code);
          }
        });
      }
    }
  }

  void sendToHome(String userId) {
    if (userId.length > 0 && userId != null && backendResult) {
      widget.onSignedIn();
    }
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingrese codigo SMS', style: TextStyle(fontSize: 15.0),),
          content: TextField(
            controller: _smsController,
            onChanged: (value) {
              setState(() {
                _smsCode = value;
              });
            },
          ),
          contentPadding: EdgeInsets.all(10.0),
          actions: <Widget>[
            FlatButton(
              child: Text('Enviar codigo de nuevo', style: TextStyle(color: primaryColor, fontSize: 12.0),),
              onPressed: () {},
            ),
            RaisedButton(
              color: primaryColor,
              child: Text('Listo', style: TextStyle(color: Colors.white, fontSize: 12.0),),
              onPressed: (_smsController.text.length > 5) ? _signInUpWithPhoneNumber : null,
            )
          ],
        );
      }
    );
  }

  void _signInUpWithPhoneNumber() async {
    print('$_verificationId ${_smsController.text}');
    if (_verificationId.length > 0 && _smsController.text.length > 0) {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsController.text,
      );
      await _authSrv.singInUpWithCredential(credential)
      .then((user) {
        print(user);
        if (_formMode == FormModeEnum.LOGIN) {
          signInBack(_phoneNumber.text, user.uid);
        } else {
          signUpBack(_phoneNumber.text, user.uid);
        }
        setState(() {
          _smsController.text = '';
        });
        Navigator.of(context).pop();
      })
      .catchError((onError) {
        setState(() {
          _smsController.text = '';
        });
        print(onError);
        _showToast('A ocurrido un error $onError');
      }); 
    }
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIos: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  void signInBack(String username, String uid) {
    setState(() => _isLoading = true);
    _userSrv.login(username, uid)
    .then((result) {
      setState(() => _isLoading = false);
      print(result);
      if (result["status"] == 200) {
        backendResult = true;
        saveData(result["data"]);
        sendToHome(uid);
      }
    })
    .catchError((error) {
      setState(() => _isLoading = false);
      print(error);
      _errorMessage = AuthErrors.getErrorMsg(error.code);
    });
  }

  void signUpBack(String username, String uid) {
    setState(() => _isLoading = true);
    _userSrv.createUser(username, uid)
    .then((result) {
      setState(() => _isLoading = false);
      if (result["data"]["reason"] != null && result["data"]["reason"] == "uuid is already registered.") {
        _showToast('EL usuario ya se encuentra registrado');
      } else {
        backendResult = true;
        print(result);
        _showToast('Usuario registrado existosamente');
      }
    })
    .catchError((error) {
      setState(() => _isLoading = false);
      print(error);
      _errorMessage = AuthErrors.getErrorMsg(error.code);
    });
  }
  
  void _verifyPhoneNumber() async {
    if (_phoneNumber.text != null && _phoneNumber.text.length > 0) {
      print('verifying');
      setState(() {
        _message = '';
        _isLoading = true;
      });
      final PhoneVerificationCompleted verificationCompleted = (AuthCredential phoneAuthCredential) {
      _firebaseAuth.signInWithCredential(phoneAuthCredential);
        setState(() {
          _isLoading = false;
          _message = 'Received phone auth credential: $phoneAuthCredential';
          print(_message);
        });
      };

      final PhoneVerificationFailed verificationFailed = (FirebaseAuthException authException) {
        setState(() {
          _isLoading = false;
          _message = 'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
          if (authException.code == 'quotaExceeded') {
            
          }
          print(_message);
        });
      };

      final PhoneCodeSent codeSent =  (String verificationId, [int forceResendingToken]) async {
        _verificationId = verificationId;
        setState(() {
          _isLoading = false;
        });
        smsCodeDialog(context);
      };

      final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
        _verificationId = verificationId;
        print('_verificationId $verificationId');
      };

      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: _phoneNumber.text,
          timeout: const Duration(seconds: 5),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout
      );
    }
  }

  Widget _showLogo() {
    return Container(
      child: Center(
        child: Image.asset('assets/firebase_logo.png', height: 160.0,),
      ),
    );
  }

  Widget _showBody() {
    return Container(
      height: MediaQuery.of(context).size.height,
      // padding: EdgeInsets.only(left: 20.0, right: 20.0),
      child: Form(
        //autovalidate: true,
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(left: 18.0, right: 18.0),
          shrinkWrap: true,
          children: <Widget>[
            _showLogo(),
            // _showSwitch(),
            // _isActiveSwitch ? _showPhoneNumberInput() : Container(),
            _isActiveSwitch ? Container() : _showEmailInput(),
            _isActiveSwitch ? Container() : _showPasswordInput(),
            _isActiveSwitch && _formMode == FormModeEnum.SIGNUP ? Container() : _showPrimaryButton(),
            _isActiveSwitch && _formMode == FormModeEnum.SIGNUP ? Container() : _showSecondaryButton() ,
            _formMode == FormModeEnum.SIGNUP ? _showBtnTerms() : Container(),
            _isActiveSwitch && _formMode == FormModeEnum.SIGNUP ? _showVerificationBtn() : Container(),
            Text(_phoneNumber.text, style: TextStyle(color: Colors.black),),
            _showErrorMessage()
          ],
        ),
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: TextFormField(
        maxLines: 1,
        autocorrect: true,
        controller: _email,
        decoration: InputDecoration(
          hintText: 'Email',
          hintStyle: new TextStyle(
            fontSize: 15.0,
          ),
          prefixIcon: IconTheme(
            data: IconThemeData(color: Colors.grey, size: 20.0),
            child: Icon(Icons.email),
          ),
        
        ),
        validator: (value) {
          if (value.isEmpty && _formMode == FormModeEnum.SIGNUP) {
            return 'Por favor ingresa el email';
          } else if (!Validator.isEmail(value) && _formMode == FormModeEnum.SIGNUP) {
            return 'Por favor ingresa un email válido';
          }

        },
      ),
    );
  }

  Widget _showPrimaryButton() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: RaisedButton(
        color: new Color.fromRGBO(148, 3, 123,1.0),
        child: _formMode == FormModeEnum.LOGIN ?
                new Text('Login', style: new TextStyle(fontSize: 18.0, color: Colors.white),) :
                new Text('Registrarse', style: new TextStyle(fontSize: 18.0, color: Colors.white)),
        onPressed: (_isLoading) ? null : _validateAndSubmit,
      ),
    );
  }

  Widget _showSecondaryButton() {
    return new FlatButton(
      child: _formMode == FormModeEnum.LOGIN
          ? new Text('Crear cuenta',
          style: new TextStyle(fontSize: 13.0, fontWeight: FontWeight.w300))
          : new Text('Tienes una cuenta? Inicia sesión!',
          style:
          new TextStyle(fontSize: 13.0, fontWeight: FontWeight.w300)),
      onPressed: _formMode == FormModeEnum.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: TextFormField(
        obscureText: true,
        maxLines: 1,
        controller: _password,
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: new TextStyle(
            fontSize: 15.0,
          ),
          prefixIcon: IconTheme(
            data: IconThemeData(color: Colors.grey, size: 20.0),
            child: Icon(Icons.lock),
          ),
        ),
        validator: (value) {
          if (value.isEmpty && _formMode == FormModeEnum.SIGNUP) {
              return 'Por favor ingresa la contraseña';
          } else if (_formMode == FormModeEnum.SIGNUP && value.length < 6) {
            return 'La contraseña debe tener al menos seis caracteres';
          }
        },
      ),
    );
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.redAccent,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showPhoneNumberInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 50.0),
      child: TextFormField(
        maxLines: 1,
        //autovalidate: true,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          //WhitelistingTextInputFormatter.digitsOnly,
          _mobileFormatter
        ],
        controller: _phoneNumber,
        decoration: InputDecoration(
          labelText: 'Teléfono (+57 3335559900)',
          labelStyle: TextStyle(
            color: primaryColor,
            decoration: TextDecoration.none
          ),
          prefixIcon: IconTheme(
            data: IconThemeData(color: Colors.grey, size: 20.0),
            child: Icon(Icons.phone_iphone),
          ), floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        validator: (value) {
          if (value.isEmpty && _formMode == FormModeEnum.SIGNUP) {
              return 'Por favor ingresa el número de teléfono';
          } 
        },
        onFieldSubmitted: (String value) {
          setState(() {
            _phoneNumber.text = value;
          });
        },
      ),
    );
  }

  Widget _showSwitch() {
    String mode = _formMode == FormModeEnum.LOGIN ? 'Iniciar sesión con número de teléfono' : 'Registrarme con número de teléfono';
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(mode, style: TextStyle(fontSize: 11.0, color: Colors.grey),),
          Switch(
            value: _isActiveSwitch,
            activeColor: primaryColor,
            onChanged: (bool onChanged) {
              print(onChanged);
              _formKey.currentState.reset();
              _phoneNumber.text = '';
              setState(() {
                _isActiveSwitch = onChanged;
              });
            },
          )
        ],
      ),
    );
  }

  Widget _showVerificationBtn() {
    return Padding(
      padding: EdgeInsets.only(top: 50.0),
      child: RaisedButton(
        color: primaryColor,
        child: Text('Verificar Número', style: TextStyle(fontSize: 15.0, color: Colors.white),),
        onPressed: (_phoneNumber.text.length == 0) ? null : () => _verifyPhoneNumber(),
      ),
    );
  }

  Widget _showBtnTerms() {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        child: Text('Terminos y condiciones', style: TextStyle(color: Colors.blueAccent, fontSize: 12.0),),
        onPressed: () => Navigator.of(context).pushNamed('/terms'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: NavBar(title: 'Login',),
      body: Stack(
        children: <Widget>[
          _showBody(),
          DialogCircularProgress(isLoading: _isLoading,)
        ],
      ),
    );
  }
}