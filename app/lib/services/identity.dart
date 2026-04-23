import 'package:app/models/invite.dart';
import 'package:app/models/register.dart';
import 'package:app/models/signin.dart';
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
    dynamic user;
    if (token != null) {
      if (await isLoggedIn()) {
        user = JwtDecoder.decode(token);
      }
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

  Future<dynamic> signin(SigninData model) async {
    dynamic body = {
      "query": 'query signin (\$input: SignIn!) { signin (input: \$input) }',
      "variables": {"input": model.toJson()},
    };

    return await ApiService.instance.post(url, body);
    /* String? token = result['data']['signin'];
    print("sign in token: ${token}");
    if (token != null) {
      // Fixed: Use correct token field from signin response
      await Storage.instance.set("token", token);
      flag = true;
    } else {
      await Storage.instance.remove("token");
    }
    return flag; */
  }

  Future<dynamic> signup(RegisterData entity) async {
    dynamic result = {};
    try {
      dynamic body = {
        "query":
            'mutation signup (\$input: SignUp!) { signup (input: \$input) { id } }',
        "variables": {"input": entity.toJson()},
      };

      result = await ApiService.instance.post(url, body);
    } catch (e) {
      throw Exception(e.toString());
    }
    return result;
  }

  Future<dynamic> verifyEmail(String otp) async {
    dynamic result = {};
    try {
      dynamic body = {
        "query":
            'mutation verify (\$otp: String!) { verifyEmail (otp: \$otp) { succeed message } }',
        "variables": {"otp": otp},
      };

      result = await ApiService.instance.post(url, body);
    } catch (e) {
      throw Exception(e.toString());
    }
    return result;
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
