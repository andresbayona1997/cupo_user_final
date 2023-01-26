import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:promociones/app_config.dart';
import '../config.dart';
import 'package:promociones/utils/globals.dart';
import 'package:promociones/services/auth_service.dart';
import 'package:dio/dio.dart' as DIO;

final JsonDecoder _decoder = new JsonDecoder();

class UserService {
  var dio = DIO.Dio(
      DIO.BaseOptions(
          baseUrl: 'https://api-dot-activaciones.appspot.com/api'
      )
  );
  final storage = new FlutterSecureStorage();
  AuthService _authService = new AuthService();
  String urlApp = AppConfig.getInstance().apiBaseUrl;

  getToken() async {
    return await storage.read(key: 'token');
  }

  Future login(String username, String uuid) async {
    Map authData = {
      "username": username,
      "uuid": uuid,
      "client_secret": clientSecret
    };

    Map<String, String> headers = {'Content-type': 'application/json'};
    final response = await dio.post('/auth/login', options: DIO.Options(
      headers: headers,
    ), data: authData);
    return _handleRequest(response);
    // var url = '/api/auth/login';
    // print(url);
    // Uri ur = new Uri.https(urlApp, url);
    // return await http
    //     .post(ur, body: jsonEncode(authData), headers: headers)
    //     .then(_handleRequest);
  }

  Future recoverPassword(String email) async{
    Map user = {
      "email": email
    };
    final response = await dio.post('/restore/password', options: DIO.Options(
      headers: {'Content-type': 'application/json'},
    ), data: user).onError((error, stackTrace) {
      print(error);
    });
    return _handleRequest(response);
  }

  Future logout() async {
    String token = await storage.read(key: 'token');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await dio.post('/auth/logout', options: DIO.Options(
      headers: headers,
    ));
    return _handleRequest(response);
    // String url = '/api/auth/logout';
    // Uri ur = new Uri.https(urlApp,url);
    // return await http.post(ur, headers: headers).then(_handleRequest);
  }

  Future<dynamic> createUser(String username, String password) async {
    Map user = {
      "username": username,
      "email": username,
      "password": password,
      "client_secret": clientSecret
    };

    Map<String, String> headers = {'Content-type': 'application/json'};

    final response = await dio.post('/register/customers', options: DIO.Options(
      headers: headers,
    ), data: user);
    return _handleRequest(response);
    // String url = '/api/register/customers';
    // print(url);
    // Uri ur = new Uri.https(urlApp,url);
    // return await http
    //     .post(ur, body: jsonEncode(user), headers: headers)
    //     .then(_handleRequest);
  }

  Future updateUser(Map user) async {
    var token = await storage.read(key: 'token');
    var id = await storage.read(key: 'id');
    String url = '/api/customers/$id';
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    print(headers);
    final response = await dio.put('/customers/$id', options: DIO.Options(
      headers: headers,
    ), data: user);
    return _handleRequest(response);
    // Uri ur = new Uri.https(urlApp,url);
    // return await http
    //     .put(ur, headers: headers, body: jsonEncode(user))
    //     .then(_handleRequest);
  }

  Future getUserById() async {
    var token = await storage.read(key: 'token');
    var id = await storage.read(key: 'id');
    String url = '/api/customers/$id';
    print('Url => $url');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await dio.get('/customers/$id', options: DIO.Options(
        headers: headers
    ));
    return _handleRequest(response);
    // print(headers);
    // Uri ur = new Uri.https(urlApp, url);
    // return await http.get(ur, headers: headers).then((http.Response response) {
    //   final String res = response.body;
    //   final int statusCode = response.statusCode;
    //   print('Code: $statusCode Response $res');
    //
    //   if (statusCode < 200 || statusCode > 400 || json == null) {
    //     throw new Exception("Error while fetching data");
    //   }
    //   return _decoder.convert(res);
    // });
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
