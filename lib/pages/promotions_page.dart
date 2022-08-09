import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:promociones/pages/detail_promotion_page.dart';
import 'package:promociones/utils/widgets/nav_bar.dart';
import 'package:promociones/utils/widgets/dialog_progress.dart';
import 'package:promociones/services/promotion_service.dart';
import 'package:promociones/utils/widgets/card_promotion.dart';
import 'package:promociones/utils/options.dart';

class PromotionsPage extends StatefulWidget {
  PromotionsPage({this.idStore, this.storeName});
  final String idStore;
  final String storeName;

  @override
  PromotionPageState createState() => PromotionPageState();
}

class PromotionPageState extends State<PromotionsPage> {
  bool _isLoading = false;
  PromotionService _promotionService = new PromotionService();
  List _promotions = [];

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.setCurrentScreen(screenName: "Promotion info page");
    _getPromotions(widget.idStore);
  }

  void _getPromotions(String idStore) {
    if (widget.idStore != null) {
      if (mounted) setState(() => _isLoading = true);
      _promotionService.getPromotionsByStore(idStore)
      .then((result) {
        if (mounted) setState(() => _isLoading = false);
        if (result != null && result["data"].length > 0) {
          if (mounted) setState(() => _promotions = result["data"]);
        }
      })
      .catchError((onError) {
        if (mounted) setState(() => _isLoading = false);
      });
    }
  }

  void _tappedPromotion(promotion) {
    if (_promotionService.validatePromotion(promotion)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _promotionService.validateTypePromotion(promotion))
      );
    } else {
      showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.all(20.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            title: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(Icons.not_interested, size: 18.0,),
                ),
                Text('Promoción no disponible', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700),),
              ],
            ),
            content: RichText(
              text: TextSpan(
                style: new TextStyle(
                  fontSize: 13.0,
                  color: Colors.black,
                  fontFamily: 'Raleway'
                ),
                children: [
                  TextSpan(text: 'Esta promoción inicia en el '),
                  TextSpan(text: promotion["date_init"], style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Raleway')),
                  TextSpan(text: ' a las '),
                  TextSpan(text: promotion["init_hour"], style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Raleway')),
                  TextSpan(text: ' y finalizará en el '),
                  TextSpan(text: promotion["date_end"], style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Raleway')),
                  TextSpan(text: ' a las '),
                  TextSpan(text: promotion["end_hour"], style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Raleway')),
                ]
              ),
            ),

            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK', style: TextStyle(color: primaryColor),),
              )
            ],
          );
        }
      );
    }
  }

  Widget _showPromotions() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(  
        shrinkWrap: true,
        padding: EdgeInsets.all(10.0),
        itemCount: _promotions.length,
        itemBuilder: (BuildContext context, int index) {
          return CardPromotion(
            promotionName: _promotions[index]["data_promotions"][0]["promotion_name"],
            imageUrl: _promotions[index]["data_promotions"][0]["imageURL"],
            dateEnd: _promotions[index]["data_promotions"][0]["date_end"],
            endHour: _promotions[index]["data_promotions"][0]["end_hour"],
            onTap: () => _tappedPromotion(_promotions[index]["data_promotions"][0]),
            description: _promotions[index]["data_promotions"][0]["description_promotion"],
          );
        },
      ),
    );
  }

  Widget _noPromotions() {
    return Container(
      child: Center(
        child: Text(
          'No hay promociones activas para esta tienda.',
          style: TextStyle(color: Colors.grey, fontSize: 14.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(title: widget.storeName,),
      body: Stack(
        children: <Widget>[
          _promotions.length > 0 ? _showPromotions() : _noPromotions(),
          DialogProgress(isLoading: _isLoading,)
        ],
      ),
    );
  }
}