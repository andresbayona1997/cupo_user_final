import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final storage = new FlutterSecureStorage();

  getValue(String key) async {
    String value = await storage.read(key: key);
    return value;
  }

  getValues() async {
    Map<String, String> allValues = await storage.readAll();   
    return allValues;
  }

  deleteValue(String key) async {
    await storage.delete(key: key);
  }

  deleteAll() async {
    await storage.deleteAll();
  }

  saveValue(String key, String value) async {
    await storage.write(key: key, value: value);
  }

}