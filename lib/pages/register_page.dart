import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:promociones/utils/widgets/dialog_progress.dart';
import 'package:promociones/utils/widgets/register_email_mode.dart';
import 'package:promociones/utils/widgets/register_phone_mode.dart';
import 'package:promociones/services/common_service.dart';


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPage createState() => new _RegisterPage();
}

enum MODE {
  PHONE_MODE,
  EMAIL_MODE
}

class _RegisterPage extends State<RegisterPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  final _formKey = new GlobalKey<FormState>();
  MODE _mode = MODE.EMAIL_MODE;
  CommonService _commonService = new CommonService();
  List _codes = [];
  bool _load = false;

  @override
  void initState() {
    super.initState();
    // _commonService.getCountryCodes()
    // .then((result) {
    //   print(result);
    //   if (result != null && result["data"].length > 0) {
    //     if (mounted) setState(() => _codes = result["data"]);
    //     // if (mounted) );
    //   }
    // })
    // .catchError((error) {
    //   print(error);
    // });
  }

  void _showSnackbar(String msg) {
    final snackBar = SnackBar(content: Text(msg, style: TextStyle(fontFamily: 'Raleway'),),);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _changeMode() {
    setState(() {
      if (_mode == MODE.EMAIL_MODE) {
        _mode = MODE.PHONE_MODE;
      } else {
        _mode = MODE.EMAIL_MODE;
      }
    });
  }

  void _loadProgress(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  Widget _showIcon() {
    return Container(
      padding: EdgeInsets.only(top: 30.0),
      child: Center(
        child: Image.asset(
          'assets/customer.png',
          height: 130.0,
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry marginCard = Theme.of(context).platform == TargetPlatform.android 
    ? EdgeInsets.only(top: 15.0, bottom: 50.0, left: 20.0, right: 20.0) 
    : EdgeInsets.only(top: 15.0, bottom: 80.0, left: 20.0, right: 20.0);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(148, 3, 123, 1.0),
        elevation: 0.0,
        title: Text('Registrarse', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17.0)),
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
              gradient: LinearGradient(
                colors: [Color.fromRGBO(148, 3, 123, 1.0), Color.fromRGBO(191, 111, 178, 1.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))
                ),
                margin: marginCard,
                child: ListView(
                  // padding: EdgeInsets.all(20.0),
                  shrinkWrap: true,
                  children: <Widget>[
                    _showIcon(),
                    // _mode == MODE.PHONE_MODE ? RegisterPhoneMode(changeMode: _changeMode, codes: _codes, loadProgress: _loadProgress, snackbar: (msg) => _showSnackbar(msg)) 
                    // : 
                    // RegisterEmailMode(changeMode: _changeMode, loadProgress: _loadProgress, snackbar: (msg) => _showSnackbar(msg)),
                    RegisterEmailMode(changeMode: _changeMode, loadProgress: (isLoading) => _loadProgress(isLoading), snackbar: (msg) => _showSnackbar(msg))
                    // _showForm()
                  ],
                ),
              ),
            )
          ),
          Positioned(
            bottom: 5.0,
            left: 50.0,
            right: 50.0,
            child: Padding(
              padding: EdgeInsets.all(3.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FlatButton(
                  onPressed: () => Navigator.of(context).pushNamed('/terms'),
                  child: Text('Terminos y condiciones', style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.w600),),
                ),
              ),
            ),
          ),
          // _showBody(),
          DialogProgress(isLoading: _isLoading,)
        ],
      ),
    );
  }
}
