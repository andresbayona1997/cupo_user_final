import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../config.dart';
import 'package:dio/dio.dart' as DIO;


final JsonDecoder _decoder = new JsonDecoder();

class GoogleService {
  var dio = DIO.Dio(
      DIO.BaseOptions(
          baseUrl: 'https://api-dot-activaciones.appspot.com/api'
      )
  );

  Future getRoute(String originLat, String originLng, double destinationLat, double destinationLng, String mode) async {
    print(mode);
    String origin = '$originLat,$originLng';
    String destination = '${destinationLat.toString()},${destinationLng.toString()}';
    //Uri url = Uri.https('$urlDirections?origin=$origin&destination=$destination&mode=$mode', '&key=$apiKey');
    //print(url);
    Uri url ;
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$destinationLat,$destinationLng';
    if (await launch(googleUrl)) {
      await canLaunch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
    return http.get(url)
    .then((http.Response response) {
      String res = response.body;
      int statusCode = response.statusCode;
      // print("API Response: " + res);
      if (statusCode < 200 || statusCode > 400 || json == null) {
        res = "{\"status\":" +
            statusCode.toString() +
            ",\"message\":\"error\",\"response\":" +
            res +
            "}";
        throw new Exception(res);
      }

      List steps;
      try {
        steps = _decoder.convert(res)["routes"][0]["legs"];
      } catch (e) {
        throw new Exception(res);
      }
      return steps;
    });
  }

  // List parseSteps(final responseBody) {
  //   var list = responseBody.map((json) => new Steps.fromJson(json)).toList();

  //   return list;
  // }

  _handleRequest(http.Response response) {
    final String res = response.body;
    final int statusCode = response.statusCode;
    print('Code: $statusCode Response $res');

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    return _decoder.convert(res);
  }
  
}