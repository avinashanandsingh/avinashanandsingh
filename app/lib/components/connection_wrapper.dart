import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectionWrapper extends StatelessWidget {
  final Widget child;

  const ConnectionWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final connectivityResult = snapshot.data;

        // If results are null or contain only 'none', show the offline screen
        if (connectivityResult == null ||
            connectivityResult.contains(ConnectivityResult.none)) {
          return const NoInternetScreen();
        }

        // Otherwise, return the actual app content
        return child;
      },
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'No Internet Connection',
              style: TextTheme.of(context).displayLarge,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Please check your settings and try again.',
                style: TextTheme.of(context).labelMedium,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Optionally trigger a manual check
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
