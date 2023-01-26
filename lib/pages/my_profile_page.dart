import 'package:flutter/material.dart';
import 'package:promociones/utils/widgets/nav_bar.dart';
import 'package:promociones/utils/options.dart';
import 'package:promociones/services/user_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:promociones/utils/widgets/dialog_progress.dart';

class MyProfilePage extends StatefulWidget {
  @override
  MyProfilePageState createState() => new MyProfilePageState();
}

class MyProfilePageState extends State<MyProfilePage> {
  UserService _userService = new UserService();
  List<TextEditingController> textEditingControllers =
      <TextEditingController>[];
  List textFieldsKeys = [];
  List<Widget> textFields = [];
  final _formKey = GlobalKey<FormState>();
  List fields = [
    {"label": "Nombre", "key": "name"},
    {"label": "Apellido", "key": "lastname"},
    {"label": "Username", "key": "username"},
    {"label": "Email", "key": "email"},
    {"label": "Dirección", "key": "address"},
    {"label": "Ciudad", "key": "city"},
    {"label": "Celular", "key": "cell_phone"},
  ];
  Map user = {
    "name": '',
    "lastname": '',
    "username": '',
    "email": '',
    "address": '',
    "city": '',
    "cell_phone": ''
  };
  bool _isLoading = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getUser() {
    setState(() => _isLoading = true);
    _userService.getUserById().then((result) {
      setState(() => _isLoading = false);
      if (result != null && result["data"] != null) {
        Map data = result["data"];
        data.forEach((key, value) {
          if (user.containsKey(key)) {
            setState(() {
              user[key] = value;
            });
          }
        });
      }
    }).catchError((onError) {
      setState(() => _isLoading = false);
    });
  }

  List<Widget> _buildTextFields() {
    textFields = [];
    fields.forEach((field) {
      TextEditingController controller = new TextEditingController.fromValue(
          TextEditingValue(text: user[field["key"]]));
      textFields.add(Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: TextFormField(
          textInputAction: TextInputAction.next,
          controller: controller,
          onSaved: (String value) {
            if (value != null && value.length > 0) {
              user[field["key"]] = value;
              FocusScope.of(context).requestFocus(new FocusNode());
            }
          },
          enabled: field["key"] == 'username' ? false : true,
          style: TextStyle(fontSize: 13.0),
          decoration: InputDecoration(
              labelText: field["label"], floatingLabelBehavior: FloatingLabelBehavior.auto),
          maxLines: 1,
          validator: (String value) {
            if (value == null || value.length == 0) {
              return 'Este campo es obligatorio';
            }
          },
        ),
      ));
    });
    return textFields;
  }

  Widget _showForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(15.0),
        shrinkWrap: true,
        children: [
          Column(
            children: _buildTextFields(),
          ),
          updateBtn(),
          TextButton(
            onPressed: (){
              Navigator.of(context).pushNamed('/passRec');
            },
            child: Text("Cambiar tu contraseña",
              style: TextStyle(
                  color: Color.fromRGBO(148, 3, 123, 1.0)
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget updateBtn() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        height: 50.0,
        child: RaisedButton(
          onPressed: (_isUpdating) ? null : update,
          color: Color.fromRGBO(148, 3, 123, 1.0),
          child: Text(
            'Actualizar',
            style: TextStyle(color: Colors.white),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
        ),
      ),
    );
  }

  void update() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _isUpdating = true;
        _isLoading = true;
      });
      _userService.updateUser(user).then((onValue) {
        setState(() {
          _isUpdating = false;
          _isLoading = false;
        });
        Fluttertoast.showToast(
            msg: 'Usuario actualizado exitosamente',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
        // getUser();
      }).catchError((onError) {
        setState(() {
          _isUpdating = false;
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(
        title: 'Mi perfil',
      ),
      body: Container(
        color: backgroundColor,
        child: Stack(
          overflow: Overflow.clip,
          children: <Widget>[
            _showForm(),
            DialogProgress(
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
