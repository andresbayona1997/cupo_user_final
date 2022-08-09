import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:promociones/app_config.dart';
import 'package:promociones/pages/detail_promotion_page.dart';
import 'package:promociones/pages/select_products_page.dart';
import 'package:promociones/utils/globals.dart';
import 'package:promociones/services/auth_service.dart';
import 'package:promociones/utils/classes/date.dart';
import 'package:dio/dio.dart' as DIO;

final JsonDecoder _decoder = new JsonDecoder();

class PromotionService {
  final storage = new FlutterSecureStorage();
  AuthService _authService = new AuthService();
  String urlApp = AppConfig
      .getInstance()
      .apiBaseUrl;
  var dio = DIO.Dio(
      DIO.BaseOptions(
          baseUrl: 'https://api-dot-activaciones.appspot.com/api'
      )
  );

  getToken() async {
    return await storage.read(key: 'token');
  }

  Widget validateTypePromotion(promotion) {
    Widget route;
    switch (promotion["type_promotion_id"]) {
      case "69s6gjv8aA59j0bwbqGp":
      case "4ieC9zgtRV4YVsc3lCov":
      case "Sj1RrthqwsY6tlwFXqZD":
      case "kVzdhcSHY83iV4Khe4II":
        route = DetailPromotionPage(
          promotionCode: promotion["promotion_code"],
          products: promotion["products"],
          listProducts: false,
        );
        break;
      case "xYERseDSmVllNuaMFUmH":
        route = DetailPromotionPage(
          promotionCode: promotion["promotion_code"],
          products: promotion["products"],
          listProducts: true,
        );
        break;
      case "lkjsH1UruLyfSvRz5kwV":
        route = SelectProductsPage(
            promotionCode: promotion["promotion_code"],
            products: promotion["products"]);
        break;
      default:
        route = DetailPromotionPage(
          promotionCode: promotion["promotion_code"],
          products: promotion["products"],
          listProducts: false,
        );
    }
    return route;
  }

  bool validatePromotion(promotion) {
    DateTime now = DateTime.now();
    String date = Date.formatDate(now, 'yyyy-MM-dd hh:mm:ss');
    String dateInitHour = promotion["date_init"] + " " + promotion["init_hour"];
    String dateEndHour = promotion["date_end"] + " " + promotion["end_hour"];

    if (Date.isInRangeDate(
        promotion["date_init"], promotion["date_end"], date) &&
        Date.isInRangeHoursMinutesSec(dateInitHour, dateEndHour, date)) {
      return true;
    } else {
      return false;
    }
  }

  Future addDirection(String description, String lat, String lng,
      String name) async {
    String url2 = "test-cuponix-dot-activaciones.uc.r.appspot.com";
    String url3 = "/api/favaddress";
    Map authData = {
      "name": name,
      "address": description,
      "latitude": lat,
      "longitude": lng
    };
    var token = await storage.read(key: 'token');
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-type': 'application/json'
    };
    final response = await dio.post('/favaddress', options: DIO.Options(
      headers: headers,
    ), data: authData);
    return _handleRequest(response);
    // Uri ur = new Uri.https(url2, url3);
    // return await http
    //     .post(ur, body: jsonEncode(authData), headers: headers);
  }

  Future getDirections() async {
    String url2 = "test-cuponix-dot-activaciones.uc.r.appspot.com";
    String url3 = "/api/favaddress";
    var token = await storage.read(key: 'token');
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-type': 'application/json'
    };

    final response = await dio.get('/favaddress', options: DIO.Options(
        headers: headers
    )).onError((error, stackTrace) {
      print(error);
    });
    return _handleRequest(response);
    // Uri ur = new Uri.https(url2, url3);
    // return await http
    //     .get(ur, headers: headers).then(_handleRequest);
    // return await http.get(ur, headers: headers).then(_handleRequest);
  }

  Future setFavoriteDirection(String idDirection) async {
    String url2 = "test-cuponix-dot-activaciones.uc.r.appspot.com";
    String url3 = "/api/favcustonaddress/" + idDirection;
    var token = await storage.read(key: 'token');
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-type': 'application/json'
    };
    Map authData = {
      "favorite": true
    };
    final response = await dio.put(
        '/favcustonaddress/' + idDirection, options: DIO.Options(
      headers: headers,
    ), data: authData);
    return _handleRequest(response);
    // Uri ur = new Uri.https(url2, url3);
    // return await http
    //     .put(ur, body: jsonEncode(authData), headers: headers);
  }

  Future deleteDirection(String idDirection) async {
    String url2 = "test-cuponix-dot-activaciones.uc.r.appspot.com";
    String url3 = "/api/favaddress/" + idDirection;
    var token = await storage.read(key: 'token');
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-type': 'application/json'
    };
    final response = await dio.delete(
        '/favaddress/' + idDirection, options: DIO.Options(
      headers: headers,
    ));
    return _handleRequest(response);
    // Uri ur = new Uri.https(url2, url3);
    // return await http
    //     .delete(ur, headers: headers);
  }


  Future getPromotions() async {
    var token = await storage.read(key: 'token');
    Map<String, String> headers = {
      'Authorization': 'Bearer $token'
    };
    final response = await dio.get('/promotions', options: DIO.Options(
        headers: headers
    ));
    return _handleRequest(response);
    // var url = '/api/promotions';
    // Uri ur = new Uri.https('test-cuponix-dot-activaciones.uc.r.appspot.com', url);
    // return await http.get(ur, headers: headers).then(_handleRequest);
  }

  Future getStores(String latitude, String longitude) async {
    var token = await storage.read(key: 'token');
    Map coords = {"latitude": latitude, "longitude": longitude};

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await dio.post('/radial/stores', options: DIO.Options(
      headers: headers,
    ), data: coords);
    return _handleRequest(response);
    // var url = '/api/radial/stores';
    // Uri ur = new Uri.https(urlApp, url);
    // return await http
    //     .post(ur, body: jsonEncode(coords), headers: headers)
    //     .then(_handleRequest);
  }

  Future getStoresWithActivePromotions(String latitude,
      String longitude) async {
    var token = await storage.read(key: 'token');
    Map coords = {"latitude": latitude, "longitude": longitude};

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final response = await dio.post(
        '/get/promotions/accepted', options: DIO.Options(
      headers: headers,
    ), data: coords).onError((error, stackTrace) {
      print(error);
    });
    return _handleRequest(response);
    // var url = '/api/get/promotions/accepted';
    // Uri ur = new Uri.https(urlApp, url);
    // return await http
    //     .post(ur, body: jsonEncode(coords), headers: headers)
    //     .then(_handleRequest);
  }

  Future getPromotionsByStore(String idStore) async {
    var token = await storage.read(key: 'token');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await dio.get(
        '/get/promotions/accepted/$idStore', options: DIO.Options(
        headers: headers
    ));
    return _handleRequest(response);
    // String url = '/api/get/promotions/accepted/$idStore';
    // Uri ur = new Uri.https('test-cuponix-dot-activaciones.uc.r.appspot.com', url);
    // return await http.get(ur, headers: headers).then(_handleRequest);
  }

  Future getPromotion(String promotionCode) async {
    var token = await storage.read(key: 'token');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await dio.get(
        '/get/promotions/$promotionCode', options: DIO.Options(
        headers: headers
    ));
    return _handleRequest(response);
    // var url = '/api/get/promotions/$promotionCode';
    // Uri ur = new Uri.https(urlApp, url);
    // return await http.get(ur, headers: headers).then(_handleRequest);
  }

  Future getRedeemedPromotions() async {
    var token = await storage.read(key: 'token');
    var id = await storage.read(key: 'id');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    print(id);
    final response = await dio.get(
        '/redeem/promotions/$id', options: DIO.Options(
        headers: headers
    ));
    return _handleRequest(response);
    // var url = '/api/redeem/promotions/$id';
    // Uri ur = new Uri.https(urlApp,url);
    // return await http.get(ur, headers: headers).then(_handleRequest);
  }

  Future acceptPromotion(String promotionCode, String uuid,
      List products) async {
    var token = await storage.read(key: 'token');
    var id = await storage.read(key: 'id');
    Map obj = {
      "promotion_code": promotionCode,
      "customer_id": id,
      "uuid": uuid,
      "products": products
    };

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await dio.post(
        '/customer/accepted/promotion', options: DIO.Options(
      headers: headers,
    ), data: obj);
    return _handleRequest(response);
    // var url = '/api/customer/accepted/promotion';
    // Uri ur = new Uri.https(urlApp,url);
    // return await http
    //     .post(ur, body: jsonEncode(obj), headers: headers)
    //     .then(_handleRequest);
  }

  signOut() async {
    try {
      await _authService.signOut();
      await storage.deleteAll();
      navigatorKey.currentState.pushReplacementNamed('/root');
    } catch (e) {
      print('SignuotError $e');
    }
  }

  _handleRequest(DIO.Response response) {
    final int statusCode = response.statusCode;
    // print('Code: $statusCode Response $res');

    if (statusCode == 401) {
      signOut();
    }

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    return response.data;
  }
}