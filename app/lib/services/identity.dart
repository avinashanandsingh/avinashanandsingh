import 'package:app/models/signup.dart';
import 'package:app/services/api.dart';
import 'package:app/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  Future<void> logout() async {
    _isAuthenticated.value = false;
    await Storage.instance.clear();
    print("User logged out.");
    notifyListeners();
  }

  /* Future<void> isLoggedIn() async {
    try {
      // Simulate a delay (e.g., fetching from server)
      String? xt = await token() ?? '';
      print("xt: ${xt}");
      if (xt.isNotEmpty) {
        dynamic body = {
          "query":
              'query verify (\$token: String!) { verify (token: \$token) }',
          "variables": {token: xt},
        };

        dynamic result = await ApiService.instance.post(
          "http://localhost:3010",
          body,
        );
        print('Data received: $result');

        _isAuthenticated.value = result?.data?.verify as bool;

        // Check if token is valid (replace with actual validation logic)
        if (_isAuthenticated.value) {
          print("User authenticated successfully.");
        } else {
          print("Login failed: Invalid or empty token.");
        }
      }
    } catch (e) {
      print("Error during login: $e");
      _isAuthenticated.value = false;
    } finally {
      // Always notify listeners when the state changes
      notifyListeners();
    }
  } */

  Future<bool> isLoggedIn() async {
    bool flag = false;
    String? token = await this.token() ?? '';
    if (token.isNotEmpty) {
      dynamic body = {
        "query": 'query verify (\$token: String!) { verify (token: \$token) }',
        "variables": {"token": token},
      };

      dynamic result = await ApiService.instance.post(url, body);
      //print('Data received: $result');

      flag = result?['data']?['verify']! as bool;
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
}
