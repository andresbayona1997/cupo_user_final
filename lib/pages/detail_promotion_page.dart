import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:promociones/utils/widgets/nav_bar.dart';
import 'package:promociones/utils/options.dart';
import 'package:promociones/services/promotion_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:promociones/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:promociones/utils/widgets/no_data_found.dart';
import 'package:promociones/utils/widgets/dialog_progress.dart';

class DetailPromotionPage extends StatefulWidget {
  DetailPromotionPage({this.promotionCode, this.products, this.listProducts});
  final String promotionCode;
  final List products;
  final bool listProducts;
  @override
  _DetailPromotionPageState createState() => _DetailPromotionPageState();
}

class _DetailPromotionPageState extends State<DetailPromotionPage> {
  User currentUser;
  PromotionService _promotionService = new PromotionService();
  AuthService _authService = new AuthService();
  bool _noDataFound = false;
  Map promotion = {
    "promotion_name": "",
    "image_url": "",
    "description_promotion": "",
    "promotion_terms": "",
    "redeem_code": "",
    "products": null,
    "type_promotion_id": ""
  };
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    if (widget.promotionCode != null) {
      _authService.getCurrentUser().then((user) {
        _promotionService
            .acceptPromotion(widget.promotionCode, user.uid, widget.products)
            .then((result) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              if (result["data"] != null) {
                var data = result["data"][0];
                promotion["image_url"] = data["imageURL"];
                promotion["promotion_name"] = data["promotion_name"];
                promotion["description_promotion"] =
                    data["description_promotion"];
                promotion["redeem_code"] = data["redeem_code"];
                promotion["promotion_terms"] =
                    result["data"][0]["promotion_terms"];
                promotion["products"] =
                    data["products"] != null ? data["products"] : [];
                promotion["type_promotion_id"] = data["type_promotion_id"];
              } else {
                _noDataFound = true;
              }
            });
          }
        }).catchError((onError) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _noDataFound = true;
            });
          }
        });
      });
    }
  }

  void _showTerms() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            title: Text(
              'Terminos y condiciones',
              style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            content: promotion["promotion_terms"] != null
                ? Text(
                    promotion["promotion_terms"],
                    style: TextStyle(fontSize: 12.0),
                    textAlign: TextAlign.justify,
                  )
                : Text(''),
          );
        });
  }

  Widget _showBody() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _showHeader(),
          _showContent(),
          // Container(child: Divider(color: primaryColor,), padding: EdgeInsets.all(15.0),),
          _showLabelProducts(),
          _showProducts(),
          _showReedemCode(),
          _showQrCode(),
          _promotionTerms()
        ],
      ),
    );
  }

  Widget _showHeader() {
    return Container(
      padding: EdgeInsets.all(15.0),
      width: MediaQuery.of(context).size.width,
      child: CachedNetworkImage(
        height: 300.0,
        width: 280.0,
        placeholder: (context, url) => SpinKitThreeBounce(
          color: Color.fromRGBO(148, 3, 123, 1.0),
          size: 25.0,
        ),
        errorWidget: (context, url, error) => new Icon(Icons.error),
        fit: BoxFit.fill,
        imageUrl: promotion["image_url"].length > 0
            ? promotion["image_url"]
            : 'http://isabelpaz.com/wp-content/themes/nucleare-pro/images/no-image-box.png',
      ),
    );
  }

  Widget _showContent() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Card(
        elevation: 1,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Icon(
                      Icons.fastfood,
                      size: 20.0,
                      color: primaryColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      promotion["promotion_name"],
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                promotion["description_promotion"],
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
                softWrap: true,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _promotionTerms() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: FlatButton(
            child: Text(
              'Terminos y condiciones',
              style: TextStyle(color: Colors.lightBlue, fontSize: 12.0),
            ),
            onPressed: () => _showTerms(),
          ),
        ),
      ),
    );
  }

  Widget _showReedemCode() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Card(
          child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Código para redimir:'),
            Text(
              promotion["redeem_code"],
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
            )
          ],
        ),
      )),
    );
  }

  Widget _showQrCode() {
    return Container(
      padding: EdgeInsets.all(20.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Center(
            child: QrImage(
              data: promotion["redeem_code"],
              size: 280.0,
            ),
          )
        ],
      ),
    );
  }

  Widget _showLabelProducts() {
    if (widget.listProducts &&
        promotion["products"] != null &&
        promotion["products"].length > 0) {
      String label = promotion["type_promotion_id"] == "xYERseDSmVllNuaMFUmH"
          ? 'Obsequio'
          : 'Productos';
      return Container(
        padding: EdgeInsets.only(left: 20.0),
        child: Text(
          label,
          style: TextStyle(
              color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 17.0),
        ),
      );
    }
    return Container();
  }

  List<Widget> _buildProducts(List products) {
    List<Widget> widgets = [];
    products.forEach((product) {
      widgets.add(
        Card(
          child: ListTile(
            title: Text(
              product["description"],
              style: TextStyle(fontSize: 14.0),
            ),
            subtitle: Text(
              'Sección: ${product["section"]}',
              style: TextStyle(fontSize: 12.0),
            ),
            // trailing: Icon(Icons.more_vert),
          ),
        ),
      );
    });
    return widgets;
  }

  Widget _showProducts() {
    if (widget.listProducts &&
        ["products"] != null &&
        promotion["products"].length > 0) {
      return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: _buildProducts(promotion["products"]),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(
        title: 'Detalle Promoción',
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: backgroundColor,
        child: Stack(
          children: <Widget>[
            _isLoading || _noDataFound ? Container() : _showBody(),
            _noDataFound ? NoDataFound() : Container(),
            DialogProgress(
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
