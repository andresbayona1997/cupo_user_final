import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:promociones/utils/widgets/nav_bar.dart';
import 'package:promociones/services/promotion_service.dart';
import 'package:promociones/utils/widgets/dialog_progress.dart';
import 'package:promociones/utils/widgets/card_promotion.dart';

class ReedemedPromotionPage extends StatefulWidget {
  _ReedemedPromotionPage createState() => new _ReedemedPromotionPage();
}

class _ReedemedPromotionPage extends State<ReedemedPromotionPage> {
  bool _isLoading = false;
  PromotionService _promotionService;
  List _reedemeed = [];

  @override
  void initState() {
    super.initState();
    _promotionService = new PromotionService();
    _isLoading = true;
    _promotionService.getRedeemedPromotions().then((result) {
      print(result);
      if (mounted) setState(() => _isLoading = false);
      if (result["status"] == 200) {
        setState(() {
          if (result["data"].length > 0) {
            _reedemeed = result["data"];
          }
        });
      }
    }).catchError((onError) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Widget _withoutReedem() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Text('No has redimido ninguna promoción'),
      ),
    );
  }

  Widget _showReedeemedPromotions() {
    return ListView.separated(
      padding: EdgeInsets.all(12.0),
      physics: ScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int index) => Divider(
        height: 0.0,
      ),
      itemCount: _reedemeed.length,
      itemBuilder: (BuildContext context, int i) {
        return CardPromotion(
          onTap: () {},
          promotionName: _reedemeed[i]["data_promotion"][0]["promotion_name"],
          imageUrl: _reedemeed[i]["data_promotion"][0]["imageURL"],
          description: _reedemeed[i]["data_promotion"][0]
              ["description_promotion"],
          dateEnd: _reedemeed[i]["data_promotion"][0]["date_end"],
          endHour: _reedemeed[i]["data_promotion"][0]["end_hour"],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(
        title: 'Mis promociones redimidas',
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            ListView(
              // shrinkWrap: true,
              children: <Widget>[
                // _isLoading ? DialogCircularProgress(isLoading: _isLoading,) : Container(),
                _reedemeed.length > 0
                    ? _showReedeemedPromotions()
                    : _withoutReedem(),
              ],
            ),
            Container(
                height: MediaQuery.of(context).size.height,
                child: DialogProgress(
                  isLoading: _isLoading,
                ))
          ],
        ),
      ),
    );
  }
}
