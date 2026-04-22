import 'dart:convert';
import 'package:app/services/storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService instance = ApiService._init();
  final store = Storage.instance;
  // Singleton instance
  ApiService._init();

  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
  Future<Map<String, dynamic>> post(String url, Object? query) async {
    final dynamic response;
    String? token = await store.get("token");
    if (token != null) {
      headers.addAll({"authorization": token});
    }
    try {
      if (query == null) {
        response = await http.post(Uri.parse(url), headers: headers);
      } else {
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(query),
        );
      }
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
