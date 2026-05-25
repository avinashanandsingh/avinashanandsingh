import 'package:app/models/inquiry.dart';
import 'package:app/models/invite.dart';
import 'package:app/models/register.dart';
import 'package:app/models/signin.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/user/signin.dart';
import 'package:app/services/api.dart';
import 'package:app/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../helpers/globals.dart';

class Identity extends ChangeNotifier {
  final ValueNotifier<bool> _isAuthenticated = ValueNotifier<bool>(false);
  final String url = dotenv.env['URL'] ?? '';
  final Storage store = Storage();
  final ApiService api = ApiService();
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
    return await store.get('token');
  }

  bool get isAuthenticated => _isAuthenticated.value;

  Future<UserData?> me() async {
    String? token = await store.get('token');
    UserData? user;
    if (token != null) {
      bool flag = await isLoggedIn();
      if (flag) {
        user = UserData.fromJson(JwtDecoder.decode(token));
      }
    }
    return user;
  }

  Future<void> logout() async {
    _isAuthenticated.value = false;
    await store.clear();
    notifyListeners();
  }

  // Verify user is logged in
  Future<bool> isLoggedIn({Widget? target}) async {
    bool flag = false;
    String? token = await this.token() ?? '';
    if (token.isNotEmpty) {
      dynamic body = {
        "query": r'query verify ($token: String!) { verify (token: $token) }',
        "variables": {"token": token},
      };

      dynamic result = await api.post(url, body);
      if (result['errors'] == null) {
        if (result?['data']?['verify'] != null) {
          flag = result?['data']?['verify']! as bool;
        }
      }
    }
    return flag;
  }

  Future<dynamic> signin(SigninData model) async {
    dynamic body = {
      "query": 'query signin (\$input: SignIn!) { signin (input: \$input) }',
      "variables": {"input": model.toJson()},
    };

    return await api.post(url, body);
  }

  Future<dynamic> signup(RegisterData entity) async {
    dynamic result = {};
    try {
      dynamic body = {
        "query":
            'mutation signup (\$input: SignUp!) { signup (input: \$input) { id } }',
        "variables": {"input": entity.toJson()},
      };

      result = await api.post(url, body);
    } catch (e) {
      throw Exception(e.toString());
    }
    return result;
  }

  Future<dynamic> forgot(String email) async {
    dynamic result;
    try {
      dynamic body = {
        "query":
            r'mutation forgot ($email: String!) { forgot (email: $email) { succeed message } }',
        "variables": {"email": email},
      };

      result = await api.post(url, body);
    } catch (e) {
      throw Exception(e.toString());
    }
    return result;
  }

  Future<dynamic> reset(String otp, String newPassword) async {
    dynamic result;
    try {
      dynamic body = {
        "query":
            r'mutation reset ($otp: String!, $password: String!) { reset (otp: $otp, password: $password) { succeed message } }',
        "variables": {"otp": otp, "password": newPassword},
      };

      result = await api.post(url, body);
    } catch (e) {
      throw Exception(e.toString());
    }
    return result;
  }

  Future<dynamic> changePassword({required String newPassword}) async {
    dynamic result = {};
    try {
      dynamic body = {
        "query":
            r'mutation changePassword ($password: String!) { changePassword (password: $password) { succeed message } }',
        "variables": {"password": newPassword},
      };

      result = await api.post(url, body);
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

      result = await api.post(url, body);
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

      result = await api.post(url, body);
    } catch (e) {
      throw Exception(e.toString());
    }
    return result;
  }

  Future<dynamic> newInquiry(InquiryData entity) async {
    dynamic result = {};
    try {
      dynamic body = {
        "query":
            'mutation add (\$input: InquiryIn!) { newInquiry (input: \$input) { id } }',
        "variables": {"input": entity.toJson()},
      };

      result = await api.post(url, body);
    } catch (e) {
      throw Exception(e.toString());
    }
    return result;
  }
}
