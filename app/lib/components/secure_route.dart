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
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Identity.instance.isLoggedIn(),
      builder: (context, snapshot) {
        // 1. While the check is running
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. If authenticated, show the target screen
        if (snapshot.hasData && snapshot.data == true) {
          return widget.child;
        }

        // 3. If not authenticated (or error), show Login
        return const SignIn();
      },
    );
  }

  @override
  void dispose() {
    widget.onAuthCheck(context);
    super.dispose();
  }
}
