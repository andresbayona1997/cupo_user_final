import 'package:firebase_database/firebase_database.dart';

class NotificationFirebase {
  String key;
  String dateInit;
  String dateEnd;
  String description;
  String initHour;
  String endHour;
  String promotionName;
  String promotionCode;
  // bool status;
  // String timestamp;
  double unixTimestamp;

  NotificationFirebase();

  NotificationFirebase.fromSnapshot(DataSnapshot snapshot)
              : key = snapshot.key,
                dateInit = snapshot.value["date_init"],
                dateEnd = snapshot.value["date_end"],
                description = snapshot.value["description"],
                initHour = snapshot.value["init_hour"],
                endHour = snapshot.value["end_hour"],
                promotionName = snapshot.value["promotion_name"],
                promotionCode = snapshot.value["promotion_code"],
                // status = snapshot.value["status"],
                // timestamp = snapshot.value["timestamp"],
                unixTimestamp = snapshot.value["unix_timestamp"]; 

  toJson() {
    return {
      "dateInit": dateInit,
      "dateEnd": dateEnd,
      "description": description,
      "initHour": initHour,
      "endHour": endHour,
      "promotionName": promotionName,
      "promotionCode": promotionCode,
      // "status": status,
      // "timestamp": timestamp,
      "unixTimestamp": unixTimestamp
    };
  }



}