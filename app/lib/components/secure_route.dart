// lib/widgets/guarded_route_widget.dart
import 'package:app/pages/signin.dart';
import 'package:app/services/identity.dart';
import 'package:flutter/material.dart';

class SecureRoute extends StatefulWidget {
  final Widget child;
  final String routeName;
  final Function(BuildContext context) onAuthCheck;

  const SecureRoute({
    super.key,
    required this.child,
    required this.routeName,
    required this.onAuthCheck,
  });

  @override
  State<SecureRoute> createState() => SecureRouteState();
}

class SecureRouteState extends State<SecureRoute> {
  bool _isAuthenticated = false;
  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final isAuth = await Identity.instance.isLoggedIn();
    setState(() {
      _isAuthenticated = isAuth;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("secure route called ${_isAuthenticated}");
    if (!_isAuthenticated) {
      // If not authenticated, navigate to sign in
      /* Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignIn()),
      ); */
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed("/signin");
      });

      // Show loading indicator
      return const Center(child: CircularProgressIndicator());
    }

    // If authenticated, show child widget
    return widget.child;
  }

  @override
  void dispose() {
    widget.onAuthCheck(context);
    super.dispose();
  }
}
