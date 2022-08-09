import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:promociones/services/common_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:promociones/services/auth_service.dart';
import 'package:promociones/services/user_service.dart';

typedef void StringCallback(String val);

class RegisterPhoneMode extends StatefulWidget {
  RegisterPhoneMode({this.changeMode, this.codes, this.loadProgress, this.snackbar});
  final VoidCallback changeMode;
  final VoidCallback loadProgress;
  final StringCallback snackbar;
  final List codes;
  _RegisterPhoneMode createState() => new _RegisterPhoneMode();
}

enum MODE {
  PHONE_MODE,
  EMAIL_MODE
}

class _RegisterPhoneMode extends State<RegisterPhoneMode> {
  int _index = 0;
  List<Step> my_steps;
  CommonService _commonService = new CommonService();
  AuthService _authSrv = new AuthService();
  List _codes = [];
  String dropdownValue;
  String _verificationId;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _phoneNumber = new TextEditingController(text: null);
  TextEditingController _smsCode = new TextEditingController(text: null);
  UserService _userService = new UserService();
  @override
  void initState() {
    super.initState();
    my_steps = [
      Step(
        isActive: true,
        state: StepState.indexed,
        title: Text("Ingresa tu número de telefono", style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),),
        content: _showSelectPhoneNumber(),
      ),
      Step(
        isActive: true,
        state: StepState.editing,
        title: Text("Verificación", style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),),
        content: _showInputVerificationCode()
      ),
    ];

  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DropdownMenuItem<String>> _buildDropdownBtns(result) {
        dropdownValue = '';
    List<DropdownMenuItem<String>> menuItems = [];
    if (result["data"] != null && result["data"].length > 0) {
      result["data"].forEach((code) {
          menuItems.add(
            DropdownMenuItem(
              value: code["phone_code"],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: new Text(code["phone_code"], style: TextStyle(color: Colors.black, fontSize: 11.0),),
                  ),
                  new Text(cutName(code["name"]), style: TextStyle(fontSize: 11.0))
                ],
              ),
            )
          );
      });
    }
    return menuItems;
  }

  void _verifyPhoneNumber() async {
    if (_phoneNumber.text != null && _phoneNumber.text.length > 0) {
      print('verifying');
      widget.loadProgress();
      final PhoneVerificationCompleted verificationCompleted = (AuthCredential phoneAuthCredential) {
        print('completed');
        widget.loadProgress();
        _firebaseAuth.signInWithCredential(phoneAuthCredential);
        // setState(() {
        //   _isLoading = false;
        //   _message = 'Received phone auth credential: $phoneAuthCredential';
        //   print(_message);
        // });
      };

      final PhoneVerificationFailed verificationFailed = (FirebaseAuthException authException) {
        widget.loadProgress();
        print(authException.message);
        setState(() {
          // _isLoading = false;
          // _message = 'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
          // if (authException.code == 'quotaExceeded') {
            
          // }
          // print(_message);
        });
      };

      final PhoneCodeSent codeSent =  (String verificationId, [int forceResendingToken]) async {
        _verificationId = verificationId;
        print(_verificationId);
        // setState(() {
        //   _isLoading = false;
        // });
        // smsCodeDialog(context);
      };

      final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
        _verificationId = verificationId;
        print('_verificationId $verificationId');
      };

      print(dropdownValue + _phoneNumber.text);
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: dropdownValue  + _phoneNumber.text,
          timeout: const Duration(seconds: 5),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout
      );
    }
  }

  void _signInUpWithPhoneNumber() async {
    if (_verificationId.length > 0 && _smsCode.text.length > 0) {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsCode.text,
      );
      
      widget.loadProgress();

      await _authSrv.singInUpWithCredential(credential)
      .then((user) {
        widget.loadProgress();
        // _userService.createUser(_phoneC, password)
      })
      .catchError((onError) {
        widget.loadProgress();
        widget.snackbar('A ocurrido un error $onError');
      }); 
    }
  }

  Widget _showInputVerificationCode() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 5.0),
            child: Text('Se te enviara un código de verificación.', style: TextStyle(fontSize: 12.0),),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: TextField(
              controller: _smsCode,
              style: TextStyle(fontSize: 14.0, letterSpacing: 1.0),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Código',
                hintStyle: TextStyle(fontSize: 12.0),
                contentPadding: EdgeInsets.all(12.0),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                ),
              )
            ),
          )
        ],
      ),
    );
  }

  Widget _showBtnChangeMode() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(top: 5.0, right: 5.0),
      child: FlatButton(
        onPressed: () => widget.changeMode(),
        child: Text('Registrate con el correo electronico', style: TextStyle(fontSize: 12.0, color: Colors.lightBlue), softWrap: true,),
      ),
    );
  }

  String cutName(String name) {
    return (name.length > 30) ? name.substring(0, 30) + '...' : name;
  }

  Widget _showSelectPhoneNumber() {
    return Container(
      height: 70.0,
      child: Column(
        children: <Widget>[
          FutureBuilder(
            future: _commonService.getCountryCodes(),
            builder: (BuildContext context, AsyncSnapshot result) {
              if (result.hasData) {
                return Expanded(
                  child: Container(
                    padding: EdgeInsets.all(1.0),
                    child: DropdownButton<String>(
                      // hint: Text('Selecciona el código del país', style: TextStyle(fontSize: 12.0, color: Colors.grey),),
                      value: dropdownValue,
                      onChanged: (String newValue) {
                        print('$newValue $dropdownValue');
                        setState(() {
                          dropdownValue = newValue;
                        });
                      },
                      items: _buildDropdownBtns(result.data),
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.only(top: 2.0, bottom: 3.0),
                  child: SpinKitThreeBounce(color: Color.fromRGBO(148, 3, 123, 1.0), size: 10.0,),
                );
              }
            },
          ),
          Expanded(
            child: Container(
              child: TextField(
                controller: _phoneNumber,
                style: TextStyle(letterSpacing: 1.0),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(12.0),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(8.0),
                    ),
                  ),
                  hintText: 'Número',
                  hintStyle: TextStyle(fontSize: 12.0),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _showStepper() {
    return Stepper(
      physics: ScrollPhysics(),
      steps: my_steps,
      currentStep: _index,
      onStepTapped: (index) {
        setState(() {
          _index = index;
        });
      },
      controlsBuilder: (BuildContext context,  ControlsDetails controls){
        return containerPlus(controls);
      },
      onStepCancel: () {
        setState(() {
          // update the variable handling the current step value
          // going back one step i.e subtracting 1, until its 0
          if (_index > 0) {
            _index = _index - 1;
          }
        });
      },
      onStepContinue: () {
        setState(() {
          if (_index == 0) {
            if (_phoneNumber.text != null && _phoneNumber.text.length > 0 && dropdownValue != null && dropdownValue.length > 0) {
              print('send code');
              if (_index < my_steps.length - 1) {
                _index = _index + 1;
              }
              _verifyPhoneNumber();
            }
          } else if (_index == 1) {
            if (_smsCode.text != null && _smsCode.text.length == 6) {
              print('Confirm code');
              if (_index < my_steps.length - 1) {
                _index = _index + 1;
              }
              _signInUpWithPhoneNumber();
            }
          }

        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _showBtnChangeMode(),
          _showStepper(),
        ],
      ),
    );
  }
}

Widget containerPlus(ControlsDetails controls){
  return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          child: Text('Cancelar', style: TextStyle(color: Colors.red),),
          onPressed: controls.onStepCancel,
        ),
        FlatButton(
          child: Text('Continuar', style: TextStyle(color: Colors.blue),),
          onPressed: controls.onStepContinue,
        )
      ],
    ),
  );
}

