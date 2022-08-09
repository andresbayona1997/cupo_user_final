import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:promociones/app_config.dart';
import 'package:promociones/models/DirectionsModel.dart';
import 'package:promociones/utils/widgets/Place.dart';
import 'package:promociones/utils/widgets/PlaceType.dart';
import 'package:promociones/utils/widgets/nav_bar.dart';
import 'package:promociones/services/promotion_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:promociones/utils/options.dart';
import 'package:promociones/utils/widgets/dialog_progress.dart';
import 'package:promociones/utils/widgets/card_promotion.dart';
import 'package:promociones/utils/widgets/search_textfield.dart';
import '../config.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PromotionService _promotionService = new PromotionService();
  Map promos = {"featured": [], "notFeatured": []};
  Future _future;
  Future _directions;
  // bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // _isLoading = true;
    _future = _promotionService.getPromotions();

  }

  @override
  void dispose() {
    super.dispose();
  }

  _buildPromotions(List promotions) {
    promos["featured"] = [];
    promos["notFeatured"] = [];
    promotions.forEach((promo) {
      if (promo["featured"]) {
        promos["featured"].add(promo);
      } else {
        promos["notFeatured"].add(promo);
      }
    });
    return promos;
  }

  Widget _buildCarousel(List promotions) {
    return Container(
      padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: CarouselSlider(
        height: 250.0,
        items: _showFeatured(promotions),
        autoPlay: true,
        initialPage: 1,
      ),
    );
  }

  void _tappedPromotion(promotion) {
    String type = promotion["type_promotion"];
    if( type!= "Publicidad"){
      FirebaseAnalytics.instance.logEvent(name: "Promotion view",
          parameters: {
            "id_promotion": promotion["promotion_code"]
          });
      if (_promotionService.validatePromotion(promotion)) {
        Widget route = _promotionService.validateTypePromotion(promotion);
        Navigator.push(context, MaterialPageRoute(builder: (context) => route));
      } else {
        showDialog(
            context: context,
            // barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                titlePadding: EdgeInsets.all(20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                title: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.not_interested,
                        size: 18.0,
                      ),
                    ),
                    Text(
                      'Promoción no disponible',
                      style:
                      TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                content: RichText(
                  text: TextSpan(
                      style: new TextStyle(
                          fontSize: 13.0,
                          color: Colors.black,
                          fontFamily: 'Raleway'),
                      children: [
                        TextSpan(text: 'Esta promoción inicia en el '),
                        TextSpan(
                            text: promotion["date_init"],
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Raleway')),
                        TextSpan(text: ' a las '),
                        TextSpan(
                            text: promotion["init_hour"],
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Raleway')),
                        TextSpan(text: ' y finalizará en el '),
                        TextSpan(
                            text: promotion["date_end"],
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Raleway')),
                        TextSpan(text: ' a las '),
                        TextSpan(
                            text: promotion["end_hour"],
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Raleway')),
                      ]),
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'OK',
                      style: TextStyle(color: primaryColor),
                    ),
                  )
                ],
              );
            });
      }
    }else{
      FirebaseAnalytics.instance.logEvent(name: "Adds view",
          parameters: {
            "id_promotion": promotion["promotion_code"]
          });
      showDialog(
          context: context,
          // barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              titlePadding: EdgeInsets.all(20.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              title: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.add_alert,
                      size: 18.0,
                    ),
                  ),
                  Text(
                    'Publicidad',
                    style:
                    TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              content: Padding(
                padding: EdgeInsets.all(8.0),
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl: promotion["imageURL"],
                  placeholder: (context, url) => SpinKitThreeBounce(
                    color: Color.fromRGBO(148, 3, 123, 1.0),
                    size: 15.0,
                  ),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'OK',
                    style: TextStyle(color: primaryColor),
                  ),
                )
              ],
            );
          });
    }
  }
  Future<String> getToken() async{
    final storage = new FlutterSecureStorage();
    var token = await storage.read(key: 'token');
    return token.toString();
  }
  List<Widget> _showFeatured(List promotions) {
    List<Widget> featured = [];
    promotions.forEach((promotion) {
      featured.add(Builder(
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: promotion["type_promotion"] == "Publicidad"?Colors.green:Colors.white
            ),
            child: Container(
              width: 300.0,
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: InkWell(
                onTap: () => _tappedPromotion(promotion),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: promotion["imageURL"],
                      placeholder: (context, url) => SpinKitThreeBounce(
                        color: Color.fromRGBO(148, 3, 123, 1.0),
                        size: 15.0,
                      ),
                      errorWidget: (context, url, error) => new Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ));
    });
    return featured;
  }

  Widget _showCarousel(promotions) {
    return Container(
      child: Column(
        children: <Widget>[
          _buildCarousel(promotions),
        ],
      ),
    );
  }

  String cutDescription(String description) {
    return (description.length > 120)
        ? description.substring(0, 120) + '...'
        : description;
  }

  Widget _listPromotions(List promotions) {
    return Container(
      padding:
          EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0, bottom: 50.0),
      child: ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        itemCount: promotions.length,
        itemBuilder: (BuildContext context, int index) {
          return CardPromotion(
            onTap: () => _tappedPromotion(promotions[index]),
            promotionName: promotions[index]["promotion_name"],
            imageUrl: promotions[index]["imageURL"],
            dateEnd: promotions[index]["date_end"],
            endHour: promotions[index]["end_hour"],
            description: promotions[index]["description_promotion"],
          );
        },
      ),
    );
  }

  Widget _notFeaturedPromotions() {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Text(
        'No hay promociones destacadas',
        style: TextStyle(color: Colors.grey, fontSize: 14.0),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: NavBar(
          title: 'Cuponix',
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: backgroundColor,
          child: Stack(
            children: <Widget>[
              ListView(
                // shrinkWrap: true,
                children: <Widget>[
                  FutureBuilder(
                    future: _future,
                    builder:
                        (BuildContext context, AsyncSnapshot futureResult) {
                      if (futureResult.hasData &&
                          futureResult.data["status"] == 200) {
                        Map promotions =
                            _buildPromotions(futureResult.data["data"]);
                        return Column(
                          children: <Widget>[
                            promotions.isNotEmpty?
                            promotions["featured"].length > 0
                                ? _showCarousel(promotions["featured"])
                                : _notFeaturedPromotions():Container(),
                            promotions["notFeatured"].length > 0
                                ? _listPromotions(promotions["notFeatured"])
                                : Container()
                          ],
                        );
                      } else if (futureResult.hasError ||
                          (futureResult.data != null &&
                              futureResult.data["status"] == 400)) {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          child: Center(
                            child: Text(
                              'No se encontraron promociones',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          child: DialogProgress(
                            isLoading: true,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
