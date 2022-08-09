
import 'package:flutter/material.dart';
import 'package:promociones/services/promotion_service.dart';
import 'package:promociones/utils/widgets/dialog_progress.dart';
import 'package:promociones/utils/widgets/nav_bar.dart';
import 'package:promociones/utils/options.dart';

class DetailPromotionProductsPage extends StatefulWidget {
  DetailPromotionProductsPage({this.promotionCode});
  final String promotionCode;
  _DetailPromotionProductsPageState createState() => _DetailPromotionProductsPageState();
}

class _DetailPromotionProductsPageState extends State<DetailPromotionProductsPage> {
  bool _isLoading;
  PromotionService _promotionService;

  @override 
  void initState() {
    super.initState();
    _isLoading = false;
    _promotionService = new PromotionService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(title: 'Detalle Promoción',),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: backgroundColor,
        child: Stack(
          children: <Widget>[
            // _isLoading || _noDataFound ? Container() : _showBody(),
            // _noDataFound ? NoDataFound() : Container(),
            DialogProgress(isLoading: _isLoading,),
          ],
        ),
      ),
    );
  }
}