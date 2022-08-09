import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:promociones/app_config.dart';
import 'package:dio/dio.dart' as DIO;

final JsonDecoder _decoder = new JsonDecoder();

class CommonService {
  String urlApp = AppConfig.getInstance().apiBaseUrl;
  var dio = DIO.Dio(
      DIO.BaseOptions(
          baseUrl: 'https://api-dot-activaciones.appspot.com/api'
      )
  );

  Future getCountryCodes() async {

    Map<String,String> headers = {
      'Content-type' : 'application/json'
    };
    final response = await dio.get('/countries/es', options: DIO.Options(
      headers: {'Content-type': 'application/json'},
    ));
    return _handleRequest(response);
    // String path = '/api/countries/es';
    // Uri url = Uri.https(urlApp, path);
    // return await http.get(url, headers: headers)
    //     .then(_handleRequest);
  }

  _handleRequest(DIO.Response response) {
    final int statusCode = response.statusCode;
    // print('Code: $statusCode Response $res');

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    return response.data;
  }
}