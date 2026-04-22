import 'dart:io';
import 'package:app/components/connection_wrapper.dart';
import 'package:app/pages/about.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/components/secure_route.dart';
import 'package:app/pages/dashboard.dart';
import 'package:app/pages/home.dart';
import 'package:app/pages/profile.dart';
import 'package:app/pages/signin.dart';
import 'package:app/pages/signup.dart';
import 'package:app/services/identity.dart';
import 'package:app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/splash.dart';

final themeProvider = ThemeProvider();
Future<Widget> _resolveInitialScreen() async {
  // Perform any async initialization here (e.g., check auth, shared prefs)
  await Future.delayed(Duration.zero); // Allow Flutter engine to settle
  return const Splash();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoldPanel',
      theme: AppTheme.lightTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      builder: (context, widget) {
        return ConnectionWrapper(child: widget!);
      },
      home: FutureBuilder<Widget>(
        future: _resolveInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return snapshot.data!;
          }
          // Show a blank loading screen while the future resolves
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ), // Default to Sign In
      /* routes: {
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
      }, */
      routes: {
        '/about': (context) => const About(),
        '/home': (context) => const Home(),
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUp(),
        '/dashboard': (context) => SecureRoute(
          routeName: '/dashboard',
          onAuthCheck: (context) {},
          child: const Dashboard(),
        ),
        '/profile': (context) => SecureRoute(
          routeName: '/profile',
          onAuthCheck: (context) {},
          child: const Profile(),
        ),
      },
    );
  }

  Future<bool> isConnected() async {
    bool flag = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        flag = true;
      }
    } on SocketException catch (_) {
      print('not connected');
    }
    return flag;
  }
}

class Authorized extends StatefulWidget {
  const Authorized({super.key});

  @override
  AuthorizedState createState() => AuthorizedState();
}

class AuthorizedState extends State<Authorized> {
  bool _isLoading = true;
  bool flag = false;
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    var result = Identity.instance.isAuthenticated;
    print("flag ${result}");
    setState(() {
      flag = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (flag) {
      return Dashboard();
    } else {
      return Home();
    }
  }
}
