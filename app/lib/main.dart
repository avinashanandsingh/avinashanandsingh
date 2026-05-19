import 'dart:io';
import 'package:app/components/connection_wrapper.dart';
import 'package:app/helpers/globals.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/splash.dart';
import 'package:app/helpers/globals.dart';

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
      navigatorKey: navigatorKey,
      title: 'Coach Avinash',
      theme: AppTheme.lightTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      /*  builder: (context, widget) {
        return ConnectionWrapper(child: widget!);
      }, */
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
      ),
      /*routes: {
        '/about': (context) => const About(),
        '/home': (context) => const Home(),
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUp(),
        '/verify': (context) => const VerifyOtp(),
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
      },*/
    );
  }
}
