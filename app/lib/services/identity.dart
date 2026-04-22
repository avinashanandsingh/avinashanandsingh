import 'package:app/models/invite.dart';
import 'package:app/models/signup.dart';
import 'package:app/services/api.dart';
import 'package:app/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Identity extends ChangeNotifier {
  final ValueNotifier<bool> _isAuthenticated = ValueNotifier<bool>(false);
  final String url = dotenv.env['URL'] ?? '';
  static final Identity instance = Identity._internal();

  // Singleton instance
  //Identity._init();

  factory Identity() {
    return instance;
  }

  Identity._internal() {
    // Set initial state to false.
    // This ensures that even if the app starts, it defaults to "not logged in".
    // This is critical to prevent unauthorized access before the token is fetched.
    _isAuthenticated.value = false;
  }

  Future<String?> token() async {
    return await Storage.instance.get('token');
  }

  bool get isAuthenticated => _isAuthenticated.value;

  Future<dynamic> me() async {
    String? token = await Storage.instance.get('token');
    Map<String, dynamic> user = {};
    if (token != null) {
      user = JwtDecoder.decode(token);
    }
    return user;
  }

  Future<void> logout() async {
    _isAuthenticated.value = false;
    await Storage.instance.clear();
    notifyListeners();
  }

  // Verify user is logged in
  Future<bool> isLoggedIn() async {
    bool flag = false;
    String? token = await this.token() ?? '';
    if (token.isNotEmpty) {
      dynamic body = {
        "query": 'query verify (\$token: String!) { verify (token: \$token) }',
        "variables": {"token": token},
      };

      dynamic result = await ApiService.instance.post(url, body);
      if (result?['data']?['verify'] != null) {
        flag = result?['data']?['verify']! as bool;
      }
    }
    return flag;
  }

  Future<bool> signin(String username, String password) async {
    bool flag = false;
    // Fixed: Use correct query for signin with username and password
    dynamic body = {
      "query": 'query signin (\$input: SignIn!) { signin (input: \$input) }',
      "variables": {
        "input": {"username": username, "password": password},
      },
    };

    Map<String, dynamic> result = await ApiService.instance.post(url, body);

    String? token = result['data']['signin'];

    if (token != null) {
      // Fixed: Use correct token field from signin response
      await Storage.instance.set("token", token);
      flag = true;
    } else {
      await Storage.instance.remove("token");
    }
    return flag;
  }

  Future<bool> signup(SignUpData entity) async {
    bool flag = false;
    print(entity.toJson());
    // Fixed: Use correct query for signin with username and password
    dynamic body = {
      "query": 'mutation signup (\$input: SignUp!) { signup (input: \$input) }',
      "variables": {"input": entity.toJson()},
    };

    Map<String, dynamic> result = await ApiService.instance.post(url, body);

    dynamic signup_data = result['data']['signup'];

    if (signup_data != null) {
      // Fixed: Use correct token field from signin response
      print(signup_data);
      flag = true;
    } else {}
    return flag;
  }

  Future<dynamic> refer(InviteData entity) async {
    dynamic result = {};
    try {
      dynamic body = {
        "query":
            'mutation refer (\$input: ReferralIn!) { refer (input: \$input) { id } }',
        "variables": {"input": entity.toJson()},
      };

      result = await ApiService.instance.post(url, body);
    } catch (e) {
      throw Exception(e.toString());
    }
    return result;
  }
}
