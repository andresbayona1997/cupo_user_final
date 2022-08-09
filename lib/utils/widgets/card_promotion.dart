import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CardPromotion extends StatelessWidget {
  CardPromotion(
      {this.onTap,
      this.imageUrl,
      this.promotionName,
      this.dateEnd,
      this.endHour,
      this.description});
  final VoidCallback onTap;
  final String imageUrl;
  final String promotionName;
  final String dateEnd;
  final String endHour;
  final String description;

  String cutString(String str, int length) {
    return (str != null && str.length > length
        ? str.substring(0, length) + ' ...'
        : str);
  }

  // Widget _validateImageUrl(String url) {
  //   print(url);
  //   Widget _widget;
  //   if (url.contains("jpg") || url.contains("jpeg") || url.contains("png")) {
  //     _widget = ;
  //   } else {
  //     _widget = Image.asset('assets/empty.jpg');
  //   }
  //   return _widget;
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: <Widget>[
              Container(
                width: 110.0,
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  height: 105.0,
                  width: 100.0,
                  imageUrl: imageUrl,
                  placeholder: (context, url) => SpinKitThreeBounce(
                    color: Color.fromRGBO(148, 3, 123, 1.0),
                    size: 15.0,
                  ),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                ),
              ),
              Expanded(
                child: Container(
                  height: 105.0,
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        cutString(promotionName, 30),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Raleway',
                            fontSize: 11.0),
                        softWrap: true,
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 2.0, left: 1.0, right: 1.0, bottom: 5.0),
                        child: Text(
                          cutString(description, 80),
                          style: TextStyle(fontSize: 9.0, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 8.0, left: 8.0, bottom: 0.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Expira en $dateEnd a las $endHour',
                            style: TextStyle(fontSize: 8.0),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
