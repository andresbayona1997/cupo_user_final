import 'package:intl/intl.dart';

class Date {

  static String parseDate(dynamic date, [String format]) {
    var parsedDate = DateTime.parse(date);
    var formatter = new DateFormat(format);
    String formattedDate = formatter.format(parsedDate);
    return formattedDate;
  }

  static String formatDate(DateTime date, String format) {
    var formatter = new DateFormat(format);
    String formattedDate = formatter.format(date);
    return formattedDate;
  }

  static int compareDates(String d1, String d2) {
    DateTime parsedD1 = DateTime.parse(d1);
    DateTime parsedD2 = DateTime.parse(d2);
    return parsedD2.difference(parsedD1).inDays;
  }

  static int compareDatesHoursMinutesSec(String h1, String h2) {
    DateTime parsedD1 = DateTime.parse(h1);
    DateTime parsedD2 = DateTime.parse(h2);
    return parsedD2.difference(parsedD1).inSeconds;
  }

  static bool isInRangeDate(String start, String end, String dateToCompare) {
    if (compareDates(start, dateToCompare) >= 0 && compareDates(dateToCompare, end) >= 0) {
      return true;
    }
    return false;
  }

  static bool isInRangeHoursMinutesSec(String start, String end, String dateToCompare) {
    if (compareDatesHoursMinutesSec(start, dateToCompare) <= 0 || compareDatesHoursMinutesSec(dateToCompare, end) > 0) {
      return true;
    }
    return false;
  }

  static String timestampToString(dynamic timestamp, String format) {
    int intTimestamp = timestamp.toInt();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(intTimestamp * 1000);
    String formattedDate = formatDate(date, format);
    return formattedDate;
  }

}