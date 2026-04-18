import 'package:flutter/material.dart';

class GlobalErrorHandler {
  static final GlobalErrorHandler instance = GlobalErrorHandler._init();

  String? _currentError;

  GlobalErrorHandler._init();

  Future<void> handleError(String message) async {
    print("🚨 Global Error: $message");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentError = message;
      // Show the overlay via the Key in main.dart
      // If you have a GlobalKey accessible to the Overlay widget
    });
  }

  void clear() {
    _currentError = null;
  }
}
