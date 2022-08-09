import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:promociones/services/promotion_service.dart';
import 'package:promociones/utils/widgets/Place.dart';
import 'package:promociones/utils/widgets/PlaceType.dart';
import 'package:promociones/utils/widgets/nav_bar.dart';
import 'package:promociones/utils/options.dart';
import 'package:promociones/services/user_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:promociones/utils/widgets/dialog_progress.dart';
import 'package:promociones/utils/widgets/search_textfield.dart';

class MyDirectionPage extends StatefulWidget {
  @override
  MyDirectionsState createState() => new MyDirectionsState();
}

class MyDirectionsState extends State<MyDirectionPage> {
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
  Future _future;
  Future _directions;
  PromotionService _promotionService = new PromotionService();

  @override
  void initState() {
    super.initState();
    _directions = _promotionService.getDirections();
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
          updateBtn()
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
  bool edit = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: NavBar(
        title: 'Mis direcciones',
      ),
      body: Container(
        color: backgroundColor,
        child: Column(
          children: <Widget>[
            Center(
              child: FutureBuilder(
                  future: _directions,
                  builder: (BuildContext context, AsyncSnapshot futureResult2) {
                    if(futureResult2.hasData && futureResult2.data["status"] == 200){
                      final list = futureResult2.data["data"] as List;
                      List listF =[];
                      var favorite;
                      var selectedValue;
                      if(list.isEmpty){
                        return addDirectionWidget(context, _promotionService);
                      }else{
                        list.forEach((element) {
                          if(element["favorite"] == true){
                            favorite = element;
                            selectedValue = element["name"];
                          }else{
                            listF.add(element);
                          }
                        });
                        if(favorite==null){
                          favorite = list.first;
                        }
                        if(edit){
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SearchMapPlaceWidget(
                                apiKey: 'AIzaSyBq1rwBZ8Jzi9OSZlhGz75gU2ppTJ0YfKU',
                                language: 'ES',
                                //strictBounds: true,
                                placeType: PlaceType.address,
                                onSelected: (Place place)async {
                                  TextEditingController control = new TextEditingController();
                                  return showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                            "Confirmar dirección"),
                                        content: Padding(
                                          padding: const EdgeInsets
                                              .all(8.0),
                                          child: Container(
                                            height: 100,
                                            child: Column(
                                              children: [
                                                Text(
                                                  "¿Estás seguro de agregar esta dirección como tu favorita?",
                                                  textAlign: TextAlign
                                                      .center,),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                TextField(
                                                  controller: control,
                                                  decoration: InputDecoration(
                                                      hintText: "Agrega nombre a la dirección"
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text(
                                                'Cancelar'),
                                            onPressed: () {
                                              Navigator.of(
                                                  context)
                                                  .pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text(
                                                'Aceptar'),
                                            onPressed: () async {
                                              Uri ur = Uri
                                                  .parse(
                                                  'https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyBq1rwBZ8Jzi9OSZlhGz75gU2ppTJ0YfKU&place_id=${place
                                                      .placeId}');
                                              //Uri ur = Uri.https('',url);
                                              final response = await http
                                                  .get(ur);
                                              final json = jsonDecode(
                                                  response
                                                      .body);
                                              if (json["error_message"] !=
                                                  null) {
                                                var error = json["error_message"];
                                                if (error ==
                                                    "This API project is not authorized to use this API.")
                                                  error +=
                                                  " Make sure the Places API is activated on your Google Cloud Platform";
                                                throw Exception(
                                                    error);
                                              } else {
                                                final predictions = json["result"]["geometry"]["location"];
                                                final lat = predictions["lat"];
                                                final lng = predictions["lng"];

                                                _promotionService
                                                    .addDirection(
                                                    place
                                                        .description,
                                                    lat
                                                        .toString(),
                                                    lng
                                                        .toString(),
                                                    control.text);
                                                Navigator
                                                    .pushNamedAndRemoveUntil(
                                                    context,
                                                    '/tabs', (
                                                    Route<
                                                        dynamic> route) => false);
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                // YOUR GOOGLE MAPS API KEY
                              ),
                              edit?
                              TextButton(
                                onPressed: (){
                                  setState(() {
                                    this.edit = false;
                                  });
                                },
                                child: Icon(Icons.cancel_presentation, color: Colors.black,size: 20,),
                              ):Container(),
                            ],
                          );
                        }else{
                          return Container(
                            height: MediaQuery.of(context).size.height-100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: DropdownButtonFormField(
                                //       value: selectedValue,
                                //       isExpanded: true,
                                //       items: list.map((e){
                                //         return DropdownMenuItem(
                                //             value: e["name"],
                                //             child: Row(
                                //               children: [
                                //                 Text(e["name"]+": "+e["address"],
                                //                   style: TextStyle(color: Colors.black, fontSize: 15),),
                                //                 TextButton(
                                //                   onPressed: (){
                                //                     setState(() {
                                //                       this.edit = true;
                                //                     });
                                //                   },
                                //                   child: Icon(Icons.edit, color: Colors.black,size: 15,),
                                //                 ),
                                //               ],
                                //             ));
                                //       }).toList()),
                                // ),
                                addDirectionWidget(context, _promotionService),
                                Container(
                                    constraints: BoxConstraints(
                                      maxHeight: 80
                                    ),
                                    child: itemDirection(favorite["name"], favorite["address"], true, _promotionService, favorite["key"], context)),
                                Flexible(
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: listF.map((e) {
                                      return itemDirection(e["name"], e["address"], false, _promotionService, e["key"], context);
                                    },
                                  ).toList(),
                                  ),
                                ),
                            ]),
                          );
                        }
                      }
                    }else{
                      return Column(
                        children: [
                          addDirectionWidget(context, _promotionService),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                            child: Text("Por ahora no tienes direcciones agregadas, añade una para disfrutar de todas las características de cuponix!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Color.fromRGBO(148, 3, 123, 1.0),
                            ),),
                          )
                        ],
                      );
                    }
                  }
              ),
            ),
            DialogProgress(
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

Widget itemDirection(String name, String address, bool favorite, PromotionService _promotionService, String directionID, BuildContext context){
  return Padding(
    padding: const EdgeInsets.symmetric(
        vertical: 3,
        horizontal: 15
    ),
    child: Center(
      child: Container(
        decoration: BoxDecoration(
          color:  Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 10)],
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(address,
                    overflow: TextOverflow.fade,
                    style: TextStyle(color: favorite?Colors.green:Colors.black, fontSize: 15),),
                  Text(name,
                    overflow: TextOverflow.fade,
                    style: TextStyle(color: favorite?Colors.green:Colors.grey, fontSize: 12),),
                ],
              ),
            ),
            favorite?
            Expanded(
              flex: 2,
              child: TextButton(
                onPressed: (){
                },
                child: Icon(Icons.star, color: Colors.yellow,size: 25,),
              ),
            ):
            Expanded(
              flex: 2,
              child: TextButton(
                onPressed: ()async {
                  return showDialog(context: context,
                  builder:(BuildContext context) {
                    return AlertDialog(
                      title: Text("Cambiar dirección favorita",
                      textAlign: TextAlign.center,),
                      content: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Container(
                          height: 100,
                          child: Column(
                            children: [
                              Text("Deseas cambiar tu dirección favorita por:"),
                              SizedBox(
                                height: 10,
                              ),
                              Text(address,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 18
                              ),)
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text(
                              'Cancelar'),
                          onPressed: () {
                            Navigator.of(context)
                                .pop();
                          },
                        ),
                        TextButton(
                          child: const Text(
                              'Aceptar'),
                          onPressed: () async{
                            FirebaseAnalytics.instance.logEvent(name: "change favorite direction");
                            await _promotionService.setFavoriteDirection(directionID);
                            Navigator.pop(context);// pop current page
                            Navigator.pop(context);
                            Navigator.pushNamed(context, "/directions");
                          },
                        ),
                      ],
                    );
                  });
                },
                child: Icon(Icons.star_border, color: Colors.yellow,size: 25,),
              ),
            ),
            favorite?
            SizedBox(
              height: 20,
            ):
            Expanded(
              flex: 1,
              child: TextButton(
                onPressed: ()async {
                  return showDialog(context: context,
                      builder:(BuildContext context) {
                        return AlertDialog(
                          title: Text("Eliminar dirección",
                            textAlign: TextAlign.center,),
                          content: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            child: Container(
                              height: 100,
                              child: Column(
                                children: [
                                  Text("¿Deseas eliminar tu dirección?:"),
                                  //Text("Tendrás que añadirla de nuevo en un futuro si la quieres volver a usar"),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(address,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 18
                                    ),)
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: const Text(
                                  'Cancelar'),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop();
                              },
                            ),
                            TextButton(
                              child: const Text(
                                  'Aceptar'),
                              onPressed: () async{
                                FirebaseAnalytics.instance.logEvent(name: "delete direction",
                                );
                                await _promotionService.deleteDirection(directionID);
                                Navigator.pop(context);// pop current page
                                Navigator.pop(context);
                                Navigator.pushNamed(context, "/directions");
                              },
                            ),
                          ],
                        );
                      });
                },
                child: Icon(Icons.delete_forever, color: Colors.red,size: 25,),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget addDirectionWidget (BuildContext context, PromotionService _promotionService){
  return SearchMapPlaceWidget(
    apiKey: 'AIzaSyBq1rwBZ8Jzi9OSZlhGz75gU2ppTJ0YfKU',
    language: 'ES',
    //strictBounds: true,
    placeType: PlaceType.address,
    onSelected: (Place place)async {
      TextEditingController control = new TextEditingController();
      return showDialog(
        context: context,
        builder:(BuildContext context) {
          return AlertDialog(
            title: Text(
                "Confirmar dirección"),
            content: Padding(
              padding: const EdgeInsets.all(
                  8.0),
              child: Container(
                height: 100,
                child: Column(
                  children: [
                    Text(
                      "¿Estás seguro de agregar esta dirección como tu favorita?",
                      textAlign: TextAlign
                          .center,),
                    SizedBox(
                      height: 5,
                    ),
                    TextField(
                      controller: control,
                      decoration: InputDecoration(
                          hintText: "Agrega nombre a la dirección"
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text(
                    'Cancelar'),
                onPressed: () {
                  Navigator.of(context)
                      .pop();
                },
              ),
              TextButton(
                child: const Text(
                    'Aceptar'),
                onPressed: () async {
                  Uri ur = Uri.parse(
                      'https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyBq1rwBZ8Jzi9OSZlhGz75gU2ppTJ0YfKU&place_id=${place
                          .placeId}');
                  //Uri ur = Uri.https('',url);
                  final response = await http
                      .get(ur);
                  final json = jsonDecode(
                      response.body);
                  if (json["error_message"] !=
                      null) {
                    var error = json["error_message"];
                    if (error ==
                        "This API project is not authorized to use this API.")
                      error +=
                      " Make sure the Places API is activated on your Google Cloud Platform";
                    throw Exception(error);
                  } else {
                    final predictions = json["result"]["geometry"]["location"];
                    final lat = predictions["lat"];
                    final lng = predictions["lng"];
                    await _promotionService
                        .addDirection(place
                        .description,
                        lat.toString(),
                        lng.toString(),
                        control.text);
                    FirebaseAnalytics.instance.logEvent(name: "add favorite direction",
                        parameters: {
                          "id_promotion": place.description
                        });
                    Navigator.pop(context);// pop current page
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/directions");
                  }
                },
              ),
            ],
          );
        },
      );
    },
    // YOUR GOOGLE MAPS API KEY
  );
}
