import 'dart:convert';
import 'dart:io';
import 'package:app/services/storage.dart';
import 'package:app/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/globals.dart';

class ApiService {
  //static final ApiService instance = ApiService._init();
  final Storage store = Storage();
  // Singleton instance
  ///ApiService._init();

  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
  Future<dynamic> post(String url, Object? query) async {
    dynamic response;
    dynamic result;
    String? token = await store.get("token");
    if (token != null) {
      headers.addAll({"authorization": token});
    }
    try {
      if (query != null) {
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(query),
        );
      } else {
        response = await http.get(Uri.parse(url), headers: headers);
      }

      result = jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
    return result;
  }

  void handleConnectionError(Object e) {
    if (e is HttpException) {
      String msg = e.message;
      Alert.show("Error: $msg", isError: true);
    } else if (e is SocketException) {
      // Use the key to show the snackbar

      if (e.osError?.errorCode == 111 ||
          e.message.contains('Connection refused')) {
        Alert.show(
          "Backend service is down. Please try again later.",
          isError: true,
        );
      } else {
        Alert.show("No internet connection.", isError: true);
      }
    }
  }
}
