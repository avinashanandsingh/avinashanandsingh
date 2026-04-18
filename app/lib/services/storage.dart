import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  final storage = const FlutterSecureStorage();
  static final Storage instance = Storage._init();

  // Singleton instance
  Storage._init();

  Future<void> set(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  Future<String?> get(String key) async {
    return await storage.read(key: key);
  }

  Future<void> remove(String key) async {
    storage.delete(key: key);
  }

  Future<void> clear() async {
    await storage.deleteAll();
  }
}
