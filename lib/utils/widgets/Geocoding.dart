
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:promociones/utils/widgets/Geolocation.dart';



class Geocoding {
  Geocoding({this.apiKey, language = 'en'});
  String apiKey;
  String language;

  Future<dynamic> getGeolocation(String adress) async {
    String trimmedAdress = adress.replaceAllMapped(' ', (m) => '+');
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=$trimmedAdress&key=$apiKey&language=$language";
    Uri ur = Uri(path: url);
    final response = await http.get(ur);
    final json = jsonDecode(response.body);
    if (json["error_message"] == null) {
      return Geolocation.fromJSON(json);
    } else {
      var error = json["error_message"];
      if (error == "This API project is not authorized to use this API.")
        error +=
        " Make sure both the Geolocation and Geocoding APIs are activated on your Google Cloud Platform";
      throw Exception(error);
    }
  }
}