import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  //final storage = const FlutterSecureStorage();
  //static final Storage instance = Storage._init();

  // Singleton instance
  //Storage._init();

  Future<void> set(String key, String value) async {
    final storage = await SharedPreferences.getInstance();
    await storage.setString(key, value);
  }

  Future<String?> get(String key) async {
    final storage = await SharedPreferences.getInstance();
    return storage.getString(key);
  }

  Future<bool> remove(String key) async {
    final storage = await SharedPreferences.getInstance();
    return await storage.remove(key);
  }

  Future<bool> clear() async {
    final storage = await SharedPreferences.getInstance();
    return await storage.clear();
  }
}
