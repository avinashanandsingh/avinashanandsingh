import 'dart:async';
import 'package:app/components/loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// for navigatorKey

class Alert {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  /// Shows a floating overlay snackbar at the top of the screen.
  /// Does not depend on Scaffold or ScaffoldMessenger.
  static void show(String message, {bool isError = false}) {
    // Dismiss any existing alert first
    dismiss();

    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _AlertOverlay(
        message: message,
        isError: isError,
        onDismissed: () {
          _removeEntry(entry);
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    // Auto-dismiss after 3 seconds
    _dismissTimer = Timer(const Duration(seconds: 3), () {
      _removeEntry(entry);
    });
  }

  /// Manually dismiss the current alert.
  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }

  static void _removeEntry(OverlayEntry entry) {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (_currentEntry == entry) {
      _currentEntry = null;
      entry.remove();
    }
  }
}

// ─── Animated overlay widget ──────────────────────────────────────────────────

class _AlertOverlay extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismissed;

  const _AlertOverlay({
    required this.message,
    required this.isError,
    required this.onDismissed,
  });

  @override
  State<_AlertOverlay> createState() => _AlertOverlayState();
}

class _AlertOverlayState extends State<_AlertOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();

    // Start exit animation shortly before auto-dismiss
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) _animateOut();
    });
  }

  void _animateOut() {
    _controller.reverse().then((_) {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bgColor = widget.isError
        ? Colors.red.shade800
        : Colors.green.shade800;
    final icon = widget.isError
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _animateOut,
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! < 0) {
                  _animateOut(); // swipe up to dismiss
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: bgColor.withAlpha(80),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _animateOut,
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
