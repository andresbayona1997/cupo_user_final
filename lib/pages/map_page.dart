import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:promociones/utils/options.dart' as prefix0;
import 'package:promociones/utils/widgets/nav_bar.dart';
import 'package:promociones/utils/options.dart';
import 'package:promociones/services/promotion_service.dart';
import 'package:promociones/services/google_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:promociones/pages/promotions_page.dart';
import 'package:promociones/utils/widgets/dialog_progress.dart';

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => new MapPageState();
}

class MapPageState extends State<MapPage> with TickerProviderStateMixin {
  GoogleMapController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PersistentBottomSheetController controllerBottomSheet;
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  int _polylineIdCounter = 1;
  final Set<Marker> _markers = {};
  bool _isLoading = false;
  bool _canDraw = false;
  Map markerTapped;
  List steps = new List();
  Location _locationService = new Location();
  PermissionStatus _permission = PermissionStatus.DENIED;
  String error;
  PromotionService _promotionService = new PromotionService();
  GoogleService _googleService = new GoogleService();
  PolylineId drawedPolyline;
  Map coords = new Map();
  Map coordsMarkerSelected = new Map();
  BitmapDescriptor _markerIcon;
  Map distance = {};
  Map duration = {};
  AnimationController _controllerFloatBtn;
  bool doneRoute = false;
  String _mode = '';

  static const List<IconData> icons = const [
    Icons.directions_walk,
    Icons.directions_car
  ];

  @override
  initState() {
    super.initState();
    _isLoading = true;
    _controllerFloatBtn = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    initPlatformState();
  }

  @override
  dispose() {
    super.dispose();
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(4.672414, -74.063829),
      zoom: 14.4746,
      tilt: 50.0,
      bearing: 45.0);

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  initPlatformState() async {
    await _locationService.changeSettings(
        accuracy: LocationAccuracy.HIGH, interval: 1000);

    LocationData location;
    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      if (serviceStatus) {
        _permission = await _locationService.requestPermission();
        if (_permission == PermissionStatus.GRANTED) {
          location = await _locationService.getLocation();
          String latitude = location.latitude.toString();
          String longitude = location.longitude.toString();
          // try {
          //   _controller.animateCamera(
          //     CameraUpdate.newLatLngZoom(
          //       LatLng(location.latitude, location.longitude),
          //       17.0,
          //     ),
          //   );
          // } catch (e) {
          //   print(e);
          // }
          coords["latitude"] = latitude;
          coords["longitude"] = longitude;
          _isLoading = true;
          getStores(latitude, longitude);
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();
        if (serviceStatusResult) {
          initPlatformState();
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        error = e.message;
      }
      location = null;
    }
  }

  _markerTapped(marker, latitude, longitude) {
    setState(() {
      doneRoute = false;
      _canDraw = true;
      markerTapped = marker;
      coordsMarkerSelected["latitude"] = latitude;
      coordsMarkerSelected["longitude"] = longitude;
      _controllerFloatBtn.forward();
    });
  }

  getStores(String latitude, String longitude) async {
    _promotionService
        .getStoresWithActivePromotions(latitude, longitude)
        .then((result) {
      setState(() => _isLoading = false);
      if (mounted) {
        setState(() {
          _markers.clear();
          polylines.clear();
        });
      }

      if (result["status"] == 201) {
        var data = result["data"];
        if (data is List) {
          if (data.length > 0) {
            for (final i in data) {
              var latitude = double.parse(i["data_shopkeeper"]["latitude"]);
              var longitude = double.parse(i["data_shopkeeper"]["longitude"]);
              if (mounted) {
                setState(() {
                  _markers.add(Marker(
                      consumeTapEvents: false,
                      onTap: () => _markerTapped(i, latitude, longitude),
                      markerId: MarkerId(i["key"]),
                      position: LatLng(latitude, longitude),
                      infoWindow: InfoWindow(
                        title: i["data_shopkeeper"]["business_name"],
                      ),
                      icon: _getMarkerType(i["data_shopkeeper"]["typology"])));
                });
              }
            }
          } else {
            _showToast('No hay tiendas cercanas');
          }
        }
      }else if(result["status"] == 201){
        _showToast('No hay tiendas cercanas');
    } else{
        _showToast('No se encontraron tiendas');
      }
    }).catchError((onError) {
      if (mounted) setState(() => _isLoading = false);
      _showToast('Error de red');
    });
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  BitmapDescriptor _getMarkerType(String typology) {
    String platform =
        Theme.of(context).platform == TargetPlatform.iOS ? 'ios' : 'android';
    print(platform);
    BitmapDescriptor bitmapDescriptor;
    switch (typology) {
      case 'MINIMERCADO':
        bitmapDescriptor = BitmapDescriptor.fromAsset(
            'assets/markers/$platform/minimarket.png');
        break;
      case 'TIENDA CABECERA':
        bitmapDescriptor = BitmapDescriptor.fromAsset(
            'assets/markers/$platform/headerstore.png');
        break;
      case 'TIENDA DE BARRIO':
        bitmapDescriptor = BitmapDescriptor.fromAsset(
            'assets/markers/$platform/neighborhoodstore.png');
        break;
      case 'TIENDA GRANDE':
        bitmapDescriptor =
            BitmapDescriptor.fromAsset('assets/markers/$platform/bigstore.png');
        break;
      default:
        bitmapDescriptor = BitmapDescriptor.fromAsset(
            'assets/markers/$platform/minimarket.png');
    }
    return bitmapDescriptor;
  }

  List<PatternItem> _getShapePolyline(String mode) {
    List<PatternItem> list = [];
    if (mode == "walking") {
      list.add(PatternItem.dot);
    }
    return list;
  }

  void drawRoute(String mode) {
    removePolylines();
    setState(() {
      _isLoading = true;
      _mode = mode;
    });
    _googleService
        .getRoute(
            coords["latitude"],
            coords["longitude"],
            coordsMarkerSelected["latitude"],
            coordsMarkerSelected["longitude"],
            mode)
        .then((result) {
      setState(() {
        _controllerFloatBtn.reverse();
        _isLoading = false;
        doneRoute = true;
      });

      if (result != null && result[0] != null) {
        setState(() {
          distance = result[0]["distance"];
          duration = result[0]["duration"];
        });

        if (result[0]["steps"].length > 0) {
          var steps = result[0]["steps"];
          steps.forEach((step) {
            setState(() {
              _markers.add(
                Marker(
                  // consumeTapEvents: true,
                  markerId: MarkerId('my_location'),
                  position: LatLng(step["start_location"]["lat"],
                      step["start_location"]["lng"]),
                  icon: Theme.of(context).platform == TargetPlatform.iOS
                      ? BitmapDescriptor.fromAsset(
                          'assets/markers/ios/person.png')
                      : BitmapDescriptor.fromAsset(
                          'assets/markers/android/person.png'),
                ),
              );
            });
            // if (step.elementAt(0) != null) {
            // }
            final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
            _polylineIdCounter++;
            final PolylineId polylineId = PolylineId(polylineIdVal);

            final Polyline polyline = Polyline(
              patterns: _getShapePolyline(mode),
              polylineId: polylineId,
              consumeTapEvents: false,
              color: new Color.fromRGBO(148, 3, 123, 1.0),
              width: 6,
              points:
                  _createPoints(step["start_location"], step["end_location"]),
              zIndex: 4,
            );
            setState(() {
              polylines[polylineId] = polyline;
              drawedPolyline = polylineId;
            });
          });
          try {
            _controller.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(double.parse(coords["latitude"]),
                    coordsMarkerSelected["longitude"]),
                17.0,
              ),
            );
          } catch (e) {}
        }
      }
    }).catchError((onError) {
      setState(() {
        _controllerFloatBtn.reverse();
        _isLoading = false;
        doneRoute = false;
      });
    });
  }

  void removePolylines() {
    setState(() {
      polylines.clear();
    });
  }

  List<LatLng> _createPoints(Map startLocation, Map endLocation) {
    final List<LatLng> points = <LatLng>[];
    points.add(_createLatLng(startLocation["lat"], startLocation["lng"]));
    points.add(_createLatLng(endLocation["lat"], endLocation["lng"]));
    return points;
  }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }

  Widget _showMap() {
    return Container(
      child: GoogleMap(
        mapToolbarEnabled: false,
        tiltGesturesEnabled: false,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: _onMapCreated,
        markers: _markers,
        polylines: Set<Polyline>.of(polylines.values),
      ),
    );
  }

  Widget _showFloatBtn() {
    return new Column(
        mainAxisSize: MainAxisSize.min,
        children: new List.generate(icons.length, (int index) {
          Widget child = new Container(
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
            child: new ScaleTransition(
              scale: new CurvedAnimation(
                parent: _controllerFloatBtn,
                curve: new Interval(0.0, 1.0 - index / icons.length / 2.0,
                    curve: Curves.easeOut),
              ),
              child: new FloatingActionButton(
                heroTag: null,
                backgroundColor: index == 0 ? Colors.blue : Colors.orange,
                mini: true,
                child: new Icon(icons[index], color: backgroundColor),
                onPressed: () => _isLoading ? null : _selectTypeRoute(index),
              ),
            ),
          );
          return child;
        }).toList()
          ..add(
            new FloatingActionButton(
              backgroundColor: primaryColor,
              heroTag: null,
              child: new AnimatedBuilder(
                animation: _controllerFloatBtn,
                builder: (BuildContext context, Widget child) {
                  return new Transform(
                    transform: new Matrix4.rotationZ(
                        _controllerFloatBtn.value * 0.5 * math.pi),
                    alignment: FractionalOffset.center,
                    child: new Icon(_controllerFloatBtn.isDismissed
                        ? Icons.directions
                        : Icons.close),
                  );
                },
              ),
              onPressed: () {
                if (_controllerFloatBtn.isDismissed) {
                  _controllerFloatBtn.forward();
                } else {
                  _controllerFloatBtn.reverse();
                }
              },
            ),
          ));
  }

  void _selectTypeRoute(index) {
    String mode = index == 0 ? "walking" : "driving";
    drawRoute(mode);
  }

  Widget _showDetailsStore() {
    return Container(
      padding: EdgeInsets.all(15.0),
      height: 200.0,
      width: 250.0,
      child: Card(
        elevation: 2,
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(3.0),
                    child: Icon(Icons.store, size: 18.0),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        markerTapped["data_shopkeeper"]["business_name"],
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 12.0),
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(3.0),
                    child: Icon(Icons.directions, size: 18.0),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 5.0),
                      child: Text(
                        '${distance["value"]} metros',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 12.0),
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                        _mode == "driving"
                            ? Icons.directions_car
                            : Icons.directions_walk,
                        size: 18.0),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, top: 5.0),
                      child: Text(
                        '${duration["text"]}',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 12.0),
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton.icon(
                    icon: Icon(
                      Icons.arrow_forward,
                      color: prefix0.primaryColor,
                    ),
                    label: Text(
                      'Ver promociones',
                      style: TextStyle(fontSize: 12.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PromotionsPage(
                                  idStore: markerTapped["shopkeeper_id"],
                                  storeName: markerTapped["data_shopkeeper"]
                                      ["business_name"])));
                    },
                  )
                ],
              )
              // Expanded(
              //   child: FlatButton(
              //     child: Text('Ver promociones', style: TextStyle(color: Colors.blueAccent),),
              //     onPressed: () {},
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: NavBar(
        title: 'Tiendas',
      ),
      body: Stack(
        children: <Widget>[
          _showMap(),
          doneRoute ? _showDetailsStore() : Container(),
          DialogProgress(
            isLoading: _isLoading,
          )
        ],
      ),
      // bottomSheet: _canDraw && markerTapped != null ? _showBottomSheet() : Container(height: 0.0, width: 0.0,),
      floatingActionButton: _canDraw && markerTapped != null
          ? _showFloatBtn()
          : Container(
              height: 0.0,
              width: 0.0,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
