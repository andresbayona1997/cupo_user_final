import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:promociones/utils/widgets/nav_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:promociones/models/notification_firebase.dart';
import 'package:promociones/utils/classes/date.dart';
import 'package:promociones/utils/options.dart';
import 'package:promociones/services/promotion_service.dart';
import 'package:promociones/pages/detail_promotion_page.dart';
import 'package:promociones/utils/widgets/dialog_progress.dart';

class NotificationPage extends StatefulWidget {
  @override
  NotificationPageState createState() => new NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  List<NotificationFirebase> _notifications = new List();
  PromotionService _promotionService = new PromotionService();
  DatabaseReference _notificationRef;
  StreamSubscription<Event> _notificationsSubscription;

  @override
  void initState() {
    super.initState();

    _notificationRef = FirebaseDatabase.instance.reference().child('customers');
    _notificationsSubscription = _notificationRef.onChildAdded.listen(_onEntryAddedNotification);
  }

  @override
  void dispose() {
    super.dispose();
    _notificationsSubscription.cancel();
  }

  _onEntryAddedNotification(Event event) {
    setState(() {
      _notifications.add(NotificationFirebase.fromSnapshot(event.snapshot));
    });
  }

  Widget withoutNotifications() {
    return new Center(
      child: new Text(
        'No hay notificaciones',
        style: new TextStyle(color: Colors.grey, fontSize: 20),
      ),
    );
  }

  Color _getColor(String endDate) {
    String parsedCurrentDate = Date.formatDate(DateTime.now(), 'yyyy-MM-dd');
    String parsedEndDate = Date.parseDate(endDate, 'yyyy-MM-dd');
    int daysLeft = Date.compareDates(parsedCurrentDate, parsedEndDate);
    Color color = (daysLeft < 0) ? Colors.grey : Colors.teal;
    return color;
  }

  int _sortList(DataSnapshot a, DataSnapshot b) {
    return b.value["unix_timestamp"].compareTo(a.value["unix_timestamp"]);
  }

  Widget showNotifications() {
    return new FirebaseAnimatedList(
      sort: _sortList,
      defaultChild: DialogProgress(
        isLoading: true,
      ),
      shrinkWrap: true,
      padding:
          new EdgeInsets.only(top: 10.0, right: 10, left: 10, bottom: 10.0),
      query: _notificationRef,
      itemBuilder:
          (_, DataSnapshot snapshot, Animation<double> animation, int index) {
        return Container(
          height: 70.0,
          child: Card(
            child: InkWell(
              splashFactory: InkRipple.splashFactory,
              onTap: () => onTapNotification(snapshot.value),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 50.0,
                    child: Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Icon(
                          Icons.notifications,
                          color: _getColor(snapshot.value["date_end"]),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 165.0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0, left: 15.0),
                        child: Text(
                          snapshot.value["promotion_name"],
                          style: TextStyle(
                              // fontFamily: 'Raleway',
                              // fontWeight: FontWeight.w700,
                              fontSize: 14.0),
                          textAlign: TextAlign.left,
                          // softWrap: true,
                          // softWrap: true,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Text(
                            Date.timestampToString(
                                snapshot.value["unix_timestamp"],
                                'dd/MM hh:mm'),
                            style: TextStyle(
                                // fontFamily: 'Raleway',
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  onTapNotification(notification) {
    FirebaseAnalytics.instance.setCurrentScreen(screenName: "Promotion page",);
    FirebaseAnalytics.instance.logEvent(name: "Promotion view",
    parameters: {
      "id_promotion": notification["promotion_code"]
    });
    if (_promotionService.validatePromotion(notification)) {
      Map promotion = {
        "type_promotion_id": notification["type_promotion_id"],
        "promotion_code": notification["promotion_code"],
        "products": notification["products"]
      };
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  _promotionService.validateTypePromotion(promotion)));
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
                          text: notification["date_init"],
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Raleway')),
                      TextSpan(text: ' a las '),
                      TextSpan(
                          text: notification["init_hour"],
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Raleway')),
                      TextSpan(text: ' y finalizará en el '),
                      TextSpan(
                          text: notification["date_end"],
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Raleway')),
                      TextSpan(text: ' a las '),
                      TextSpan(
                          text: notification["end_hour"],
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: NavBar(title: 'Notificaciones'),
        body: Container(
          color: backgroundColor,
          padding: EdgeInsets.all(0.0),
          height: MediaQuery.of(context).size.height,
          child: _notifications.length == 0
              ? withoutNotifications()
              : showNotifications(),
        ));
  }
}
