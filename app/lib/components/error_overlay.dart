// lib/widgets/error_overlay.dart

import 'package:flutter/material.dart';

class ErrorOverlay extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;
  final IconData? icon;

  const ErrorOverlay({
    super.key,
    required this.title,
    required this.message,
    this.onDismiss,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    // Check if this should be displayed (Managed by state, but here simplified for direct widget)
    return Container(
      constraints: const BoxConstraints.expand(), // Full screen overlay
      decoration: const BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.zero, // No border radius
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: onDismiss ?? () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text("Dismiss Error"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
